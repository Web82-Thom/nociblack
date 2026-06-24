-- NociBlacK V1 - Permanent item deletion security and consistency test

begin;

do $$
declare
  run_token text := replace(gen_random_uuid()::text, '-', '');
  super_admin_id uuid;
  admin_id uuid;
  category_id uuid;
  admin_item_id uuid;
  super_admin_item_id uuid;
  inactive_admin_item_id uuid;
begin
  select id
  into super_admin_id
  from public.profiles
  where role = 'SUPER_ADMIN'
    and is_active
  order by created_at
  limit 1;

  select id
  into admin_id
  from public.profiles
  where role = 'ADMIN'
    and is_active
  order by created_at
  limit 1;

  if super_admin_id is null then
    raise exception 'TEST SETUP FAILED: active SUPER_ADMIN profile missing';
  end if;

  if admin_id is null then
    raise exception 'TEST SETUP FAILED: active ADMIN profile missing';
  end if;

  insert into public.categories (name, slug)
  values (
    'Deletion fixture ' || run_token,
    'deletion-fixture-' || run_token
  )
  returning id into category_id;

  insert into public.items (
    category_id,
    title,
    slug,
    price_cents,
    stock_quantity,
    sku
  )
  values
    (
      category_id,
      'ADMIN deletion fixture',
      'admin-deletion-' || run_token,
      1000,
      1,
      'ADMIN-DELETE-' || run_token
    ),
    (
      category_id,
      'SUPER_ADMIN deletion fixture',
      'super-admin-deletion-' || run_token,
      1100,
      1,
      'SUPER-DELETE-' || run_token
    ),
    (
      category_id,
      'Inactive ADMIN deletion fixture',
      'inactive-admin-deletion-' || run_token,
      1200,
      1,
      'INACTIVE-DELETE-' || run_token
    );

  select id into admin_item_id
  from public.items
  where slug = 'admin-deletion-' || run_token;

  select id into super_admin_item_id
  from public.items
  where slug = 'super-admin-deletion-' || run_token;

  select id into inactive_admin_item_id
  from public.items
  where slug = 'inactive-admin-deletion-' || run_token;

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values
    (
      admin_item_id,
      'item-images/items/' || admin_item_id
        || '/00000000-0000-4000-8000-000000000001.jpg',
      1,
      true
    ),
    (
      admin_item_id,
      'item-images/items/' || admin_item_id
        || '/00000000-0000-4000-8000-000000000002.jpg',
      2,
      false
    ),
    (
      super_admin_item_id,
      'item-images/items/' || super_admin_item_id
        || '/00000000-0000-4000-8000-000000000001.jpg',
      1,
      true
    );

  -- The workflow must also delete a currently published article, not only a
  -- draft or an archive.
  update public.items
  set status = 'PUBLISHED'
  where id = admin_item_id;

  perform set_config('nociblack_test.super_admin_id', super_admin_id::text, true);
  perform set_config('nociblack_test.admin_id', admin_id::text, true);
  perform set_config('nociblack_test.admin_item_id', admin_item_id::text, true);
  perform set_config(
    'nociblack_test.super_admin_item_id',
    super_admin_item_id::text,
    true
  );
  perform set_config(
    'nociblack_test.inactive_admin_item_id',
    inactive_admin_item_id::text,
    true
  );
end;
$$;

-------------------------------------------------------------------------------
-- Visiteur public
-------------------------------------------------------------------------------

set local role anon;

do $$
declare
  target_item_id uuid := current_setting('nociblack_test.admin_item_id')::uuid;
  rejection_detected boolean := false;
begin
  begin
    perform * from public.delete_item_permanently(target_item_id);
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: anon can permanently delete an item';
  end if;
end;
$$;

reset role;

-------------------------------------------------------------------------------
-- ADMIN actif
-------------------------------------------------------------------------------

do $claims$
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object(
      'sub',
      current_setting('nociblack_test.admin_id'),
      'role',
      'authenticated'
    )::text,
    true
  );
end;
$claims$;

set local role authenticated;

do $$
declare
  target_item_id uuid := current_setting('nociblack_test.admin_item_id')::uuid;
  affected_rows integer := 0;
  returned_jobs integer;
  pending_job_ids uuid[];
begin
  -- Direct table deletion stays unavailable: clients must use the RPC so
  -- Storage cleanup is never bypassed.
  begin
    delete from public.items
    where id = target_item_id;

    get diagnostics affected_rows = row_count;
  exception
    when insufficient_privilege then
      affected_rows := 0;
  end;

  if affected_rows <> 0 then
    raise exception 'TEST FAILED: ADMIN bypassed permanent deletion RPC';
  end if;

  select count(*)
  into returned_jobs
  from public.delete_item_permanently(target_item_id);

  if returned_jobs <> 2 then
    raise exception 'TEST FAILED: ADMIN deletion did not queue both images';
  end if;

  if exists (select 1 from public.items where id = target_item_id) then
    raise exception 'TEST FAILED: ADMIN item was not deleted';
  end if;

  if exists (
    select 1
    from public.item_images as image
    where image.item_id = target_item_id
  ) then
    raise exception 'TEST FAILED: ADMIN item image references were not cascaded';
  end if;

  select array_agg(job.job_id order by job.job_id)
  into pending_job_ids
  from public.get_pending_item_storage_deletions(100) as job
    where job.object_name like 'items/' || target_item_id::text || '/%';

  if cardinality(pending_job_ids) <> 2 then
    raise exception 'TEST FAILED: ADMIN cannot resume pending Storage cleanup';
  end if;

  perform public.complete_item_storage_deletions(pending_job_ids);

  if exists (
    select 1
    from public.get_pending_item_storage_deletions(100) as job
    where job.object_name like 'items/' || target_item_id::text || '/%'
  ) then
    raise exception 'TEST FAILED: ADMIN cannot complete Storage cleanup jobs';
  end if;
end;
$$;

reset role;

-------------------------------------------------------------------------------
-- SUPER_ADMIN actif
-------------------------------------------------------------------------------

do $claims$
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object(
      'sub',
      current_setting('nociblack_test.super_admin_id'),
      'role',
      'authenticated'
    )::text,
    true
  );
end;
$claims$;

set local role authenticated;

do $$
declare
  target_item_id uuid :=
    current_setting('nociblack_test.super_admin_item_id')::uuid;
  admin_id uuid := current_setting('nociblack_test.admin_id')::uuid;
  returned_jobs integer;
begin
  select count(*)
  into returned_jobs
  from public.delete_item_permanently(target_item_id);

  if returned_jobs <> 1 then
    raise exception 'TEST FAILED: SUPER_ADMIN deletion did not queue its image';
  end if;

  if exists (select 1 from public.items where id = target_item_id) then
    raise exception 'TEST FAILED: SUPER_ADMIN item was not deleted';
  end if;

  update public.profiles
  set is_active = false
  where id = admin_id;
end;
$$;

reset role;

-------------------------------------------------------------------------------
-- ADMIN désactivé
-------------------------------------------------------------------------------

do $claims$
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object(
      'sub',
      current_setting('nociblack_test.admin_id'),
      'role',
      'authenticated'
    )::text,
    true
  );
end;
$claims$;

set local role authenticated;

do $$
declare
  target_item_id uuid :=
    current_setting('nociblack_test.inactive_admin_item_id')::uuid;
  rejection_detected boolean := false;
begin
  begin
    perform * from public.delete_item_permanently(target_item_id);
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: inactive ADMIN can permanently delete an item';
  end if;
end;
$$;

reset role;

do $$
declare
  target_item_id uuid :=
    current_setting('nociblack_test.inactive_admin_item_id')::uuid;
begin
  if not exists (select 1 from public.items where id = target_item_id) then
    raise exception 'TEST FAILED: inactive ADMIN deletion removed the item';
  end if;
end;
$$;

rollback;
