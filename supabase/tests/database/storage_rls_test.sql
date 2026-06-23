-- NociBlacK V1 - Supabase Storage RLS regression test
-- Metadata fixtures are inserted in storage.objects and removed by ROLLBACK.

begin;

do $$
declare
  run_token text := replace(gen_random_uuid()::text, '-', '');
  super_admin_id uuid;
  admin_id uuid;
  category_id uuid;
  published_item_id uuid;
  draft_item_id uuid;
  published_object_name text;
  draft_object_name text;
  valid_brand_name text;
  invalid_brand_name text;
  rejection_detected boolean;
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

  -- Supabase interdit les UPDATE/DELETE directs sur storage.objects. Leur
  -- présence est contrôlée ici, puis leur comportement sera testé via l’API
  -- Storage lors de l’intégration des clients.
  if (
    select count(*)
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname in (
        'item_images_storage_admin_update',
        'item_images_storage_admin_delete',
        'brand_assets_storage_super_admin_update',
        'brand_assets_storage_super_admin_delete'
      )
  ) <> 4 then
    raise exception 'TEST SETUP FAILED: Storage mutation policies missing';
  end if;

  insert into public.categories (name, slug)
  values (
    'Storage test ' || run_token,
    'storage-test-' || run_token
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
  values (
    category_id,
    'Published Storage item',
    'published-storage-' || run_token,
    1000,
    1,
    'STORAGE-PUBLISHED-' || run_token
  )
  returning id into published_item_id;

  insert into public.items (
    category_id,
    title,
    slug,
    price_cents,
    stock_quantity,
    sku
  )
  values (
    category_id,
    'Draft Storage item',
    'draft-storage-' || run_token,
    1000,
    1,
    'STORAGE-DRAFT-' || run_token
  )
  returning id into draft_item_id;

  published_object_name := published_item_id || '/image_1.webp';
  draft_object_name := draft_item_id || '/image_1.webp';
  valid_brand_name := 'public/test_' || run_token || '.png';
  invalid_brand_name := 'private/test_' || run_token || '.png';

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    published_item_id,
    'item-images/' || published_object_name,
    1,
    true
  );

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    draft_item_id,
    'item-images/' || draft_object_name,
    1,
    true
  );

  update public.items
  set status = 'PUBLISHED'
  where id = published_item_id;

  insert into storage.objects (bucket_id, name)
  values
    ('item-images', published_object_name),
    ('item-images', draft_object_name),
    ('brand-assets', valid_brand_name),
    ('brand-assets', invalid_brand_name);

  -- La base refuse une référence qui ne correspond pas à sa position.
  rejection_detected := false;

  begin
    insert into public.item_images (
      item_id,
      image_url,
      display_order,
      is_primary
    )
    values (
      draft_item_id,
      'item-images/' || draft_item_id || '/wrong-name.webp',
      2,
      false
    );
  exception
    when check_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: invalid item_images path accepted';
  end if;

  perform set_config(
    'nociblack_test.run_token',
    run_token,
    true
  );

  perform set_config(
    'nociblack_test.super_admin_id',
    super_admin_id::text,
    true
  );

  perform set_config(
    'nociblack_test.admin_id',
    admin_id::text,
    true
  );

  perform set_config(
    'nociblack_test.draft_item_id',
    draft_item_id::text,
    true
  );

  perform set_config(
    'nociblack_test.published_object_name',
    published_object_name,
    true
  );

  perform set_config(
    'nociblack_test.draft_object_name',
    draft_object_name,
    true
  );

  perform set_config(
    'nociblack_test.valid_brand_name',
    valid_brand_name,
    true
  );

  perform set_config(
    'nociblack_test.invalid_brand_name',
    invalid_brand_name,
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
  published_object_name text :=
    current_setting('nociblack_test.published_object_name');
  draft_object_name text :=
    current_setting('nociblack_test.draft_object_name');
  valid_brand_name text :=
    current_setting('nociblack_test.valid_brand_name');
  invalid_brand_name text :=
    current_setting('nociblack_test.invalid_brand_name');
  rejection_detected boolean;
begin
  if not exists (
    select 1
    from storage.objects
    where bucket_id = 'item-images'
      and name = published_object_name
  ) then
    raise exception 'TEST FAILED: published item image is not public';
  end if;

  if exists (
    select 1
    from storage.objects
    where bucket_id = 'item-images'
      and name = draft_object_name
  ) then
    raise exception 'TEST FAILED: draft item image is public';
  end if;

  if not exists (
    select 1
    from storage.objects
    where bucket_id = 'brand-assets'
      and name = valid_brand_name
  ) then
    raise exception 'TEST FAILED: valid brand asset is not public';
  end if;

  if exists (
    select 1
    from storage.objects
    where bucket_id = 'brand-assets'
      and name = invalid_brand_name
  ) then
    raise exception 'TEST FAILED: invalid brand path is public';
  end if;

  rejection_detected := false;

  begin
    insert into storage.objects (bucket_id, name)
    values ('brand-assets', 'public/forbidden.png');
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: anon can upload brand assets';
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
  run_token text := current_setting('nociblack_test.run_token');
  draft_item_id uuid :=
    current_setting('nociblack_test.draft_item_id')::uuid;
  draft_object_name text :=
    current_setting('nociblack_test.draft_object_name');
  admin_object_name text;
  rejection_detected boolean;
begin
  if not exists (
    select 1
    from storage.objects
    where bucket_id = 'item-images'
      and name = draft_object_name
  ) then
    raise exception 'TEST FAILED: ADMIN cannot read draft item images';
  end if;

  admin_object_name := draft_item_id || '/image_2.webp';

  insert into storage.objects (bucket_id, name)
  values ('item-images', admin_object_name);

  if not exists (
    select 1
    from storage.objects
    where bucket_id = 'item-images'
      and name = admin_object_name
  ) then
    raise exception 'TEST FAILED: ADMIN cannot upload item images';
  end if;

  rejection_detected := false;

  begin
    insert into storage.objects (bucket_id, name)
    values (
      'item-images',
      draft_item_id || '/image_4.webp'
    );
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: invalid item image path accepted';
  end if;

  rejection_detected := false;

  begin
    insert into storage.objects (bucket_id, name)
    values (
      'brand-assets',
      'public/admin_forbidden_' || run_token || '.png'
    );
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: ADMIN can upload brand assets';
  end if;

  -- UPDATE et DELETE passent obligatoirement par l’API Storage et ne sont donc
  -- jamais exécutés directement contre storage.objects dans ce test SQL.
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
  run_token text := current_setting('nociblack_test.run_token');
  admin_id uuid := current_setting('nociblack_test.admin_id')::uuid;
  super_brand_name text :=
    'public/super_' || run_token || '.webp';
  affected_rows integer;
  rejection_detected boolean;
begin
  insert into storage.objects (bucket_id, name)
  values ('brand-assets', super_brand_name);

  if not exists (
    select 1
    from storage.objects
    where bucket_id = 'brand-assets'
      and name = super_brand_name
  ) then
    raise exception 'TEST FAILED: SUPER_ADMIN cannot upload brand assets';
  end if;

  rejection_detected := false;

  begin
    insert into storage.objects (bucket_id, name)
    values (
      'brand-assets',
      'private/invalid_' || run_token || '.webp'
    );
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: invalid brand path accepted';
  end if;

  -- Désactivation temporaire de l’ADMIN pour tester la révocation Storage.
  update public.profiles
  set is_active = false
  where id = admin_id;

  get diagnostics affected_rows = row_count;

  if affected_rows <> 1 then
    raise exception 'TEST FAILED: cannot deactivate ADMIN for Storage test';
  end if;
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
  draft_item_id uuid :=
    current_setting('nociblack_test.draft_item_id')::uuid;
  draft_object_name text :=
    current_setting('nociblack_test.draft_object_name');
  rejection_detected boolean;
begin
  if exists (
    select 1
    from storage.objects
    where bucket_id = 'item-images'
      and name = draft_object_name
  ) then
    raise exception 'TEST FAILED: inactive ADMIN can read draft images';
  end if;

  rejection_detected := false;

  begin
    insert into storage.objects (bucket_id, name)
    values (
      'item-images',
      draft_item_id || '/image_2.webp'
    );
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: inactive ADMIN can upload item images';
  end if;
end;
$$;

reset role;
rollback;
