-- NociBlacK V1 - ADMIN and SUPER_ADMIN RLS regression test
-- Existing active profiles are discovered automatically. No UUID is stored.

begin;

do $$
declare
  run_token text := replace(gen_random_uuid()::text, '-', '');
  super_admin_id uuid;
  admin_id uuid;
  fixture_category_id uuid;
  fixture_draft_item_id uuid;
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

  -- Fixture privée : un brouillon qu’un visiteur public ne peut pas lire.
  insert into public.categories (name, slug)
  values (
    'RLS fixture ' || run_token,
    'rls-fixture-' || run_token
  )
  returning id into fixture_category_id;

  insert into public.items (
    category_id,
    title,
    slug,
    price_cents,
    stock_quantity,
    sku
  )
  values (
    fixture_category_id,
    'Private draft fixture',
    'private-draft-' || run_token,
    1000,
    1,
    'PRIVATE-' || run_token
  )
  returning id into fixture_draft_item_id;

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    fixture_draft_item_id,
    'item-images/' || fixture_draft_item_id || '/image_1.webp',
    1,
    true
  );

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
    'nociblack_test.fixture_category_id',
    fixture_category_id::text,
    true
  );

  perform set_config(
    'nociblack_test.fixture_draft_item_id',
    fixture_draft_item_id::text,
    true
  );
end;
$$;

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
  admin_id uuid := current_setting('nociblack_test.admin_id')::uuid;
  super_admin_id uuid :=
    current_setting('nociblack_test.super_admin_id')::uuid;
  fixture_category_id uuid :=
    current_setting('nociblack_test.fixture_category_id')::uuid;
  fixture_draft_item_id uuid :=
    current_setting('nociblack_test.fixture_draft_item_id')::uuid;
  admin_category_id uuid;
  admin_item_id uuid;
  affected_rows integer;
  rejection_detected boolean;
begin
  if not public.is_active_admin() then
    raise exception 'TEST FAILED: ADMIN is not recognized as active';
  end if;

  if public.is_active_super_admin() then
    raise exception 'TEST FAILED: ADMIN is recognized as SUPER_ADMIN';
  end if;

  -- Un ADMIN lit uniquement son propre profil.
  if (
    select count(*)
    from public.profiles
  ) <> 1 then
    raise exception 'TEST FAILED: ADMIN profile visibility';
  end if;

  if not exists (
    select 1
    from public.profiles
    where id = admin_id
  ) then
    raise exception 'TEST FAILED: ADMIN cannot read own profile';
  end if;

  if exists (
    select 1
    from public.profiles
    where id = super_admin_id
  ) then
    raise exception 'TEST FAILED: ADMIN can read SUPER_ADMIN profile';
  end if;

  -- Un ADMIN lit également les brouillons.
  if not exists (
    select 1
    from public.items
    where id = fixture_draft_item_id
      and status = 'DRAFT'
  ) then
    raise exception 'TEST FAILED: ADMIN cannot read draft items';
  end if;

  -- Création et modification d’une catégorie.
  insert into public.categories (name, slug)
  values (
    'ADMIN category ' || run_token,
    'admin-category-' || run_token
  )
  returning id into admin_category_id;

  update public.categories
  set description = 'Updated by ADMIN'
  where id = admin_category_id;

  get diagnostics affected_rows = row_count;

  if affected_rows <> 1 then
    raise exception 'TEST FAILED: ADMIN cannot update categories';
  end if;

  -- Création et publication d’un article.
  insert into public.items (
    category_id,
    title,
    slug,
    price_cents,
    stock_quantity,
    sku
  )
  values (
    admin_category_id,
    'ADMIN item',
    'admin-item-' || run_token,
    1200,
    2,
    'ADMIN-' || run_token
  )
  returning id into admin_item_id;

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    admin_item_id,
    'item-images/' || admin_item_id || '/image_1.webp',
    1,
    true
  );

  update public.items
  set status = 'PUBLISHED'
  where id = admin_item_id;

  if not exists (
    select 1
    from public.items
    where id = admin_item_id
      and status = 'PUBLISHED'
  ) then
    raise exception 'TEST FAILED: ADMIN cannot publish items';
  end if;

  -- Une image secondaire peut être ajoutée puis supprimée.
  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    admin_item_id,
    'item-images/' || admin_item_id || '/image_2.webp',
    2,
    false
  );

  delete from public.item_images
  where item_id = admin_item_id
    and display_order = 2;

  get diagnostics affected_rows = row_count;

  if affected_rows <> 1 then
    raise exception 'TEST FAILED: ADMIN cannot delete item images';
  end if;

  -- Un ADMIN ne peut modifier aucun profil, même le sien.
  update public.profiles
  set first_name = 'Forbidden'
  where id = admin_id;

  get diagnostics affected_rows = row_count;

  if affected_rows <> 0 then
    raise exception 'TEST FAILED: ADMIN can update own profile';
  end if;

  -- Aucune suppression physique des articles n’est accordée.
  rejection_detected := false;

  begin
    delete from public.items
    where id = admin_item_id;
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: ADMIN received item DELETE privilege';
  end if;

  perform set_config(
    'nociblack_test.admin_category_id',
    admin_category_id::text,
    true
  );

  -- Vérifie également l’accès à une fixture créée hors session.
  if not exists (
    select 1
    from public.categories
    where id = fixture_category_id
  ) then
    raise exception 'TEST FAILED: ADMIN cannot read all categories';
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
  super_admin_id uuid :=
    current_setting('nociblack_test.super_admin_id')::uuid;
  admin_id uuid := current_setting('nociblack_test.admin_id')::uuid;
  admin_category_id uuid :=
    current_setting('nociblack_test.admin_category_id')::uuid;
  affected_rows integer;
begin
  if not public.is_active_admin() then
    raise exception 'TEST FAILED: SUPER_ADMIN lacks ADMIN rights';
  end if;

  if not public.is_active_super_admin() then
    raise exception 'TEST FAILED: SUPER_ADMIN is not recognized';
  end if;

  -- Le SUPER_ADMIN voit les deux profils.
  if not exists (
    select 1
    from public.profiles
    where id = super_admin_id
  ) or not exists (
    select 1
    from public.profiles
    where id = admin_id
  ) then
    raise exception 'TEST FAILED: SUPER_ADMIN profile visibility';
  end if;

  -- Le SUPER_ADMIN peut gérer le profil ADMIN.
  update public.profiles
  set first_name = 'Temporary test value'
  where id = admin_id;

  get diagnostics affected_rows = row_count;

  if affected_rows <> 1 then
    raise exception 'TEST FAILED: SUPER_ADMIN cannot update ADMIN profile';
  end if;

  -- Le SUPER_ADMIN possède également les droits catalogue.
  update public.categories
  set description = 'Updated by SUPER_ADMIN'
  where id = admin_category_id;

  get diagnostics affected_rows = row_count;

  if affected_rows <> 1 then
    raise exception 'TEST FAILED: SUPER_ADMIN lacks catalogue rights';
  end if;

  -- Désactivation temporaire pour vérifier la perte immédiate des droits.
  update public.profiles
  set is_active = false
  where id = admin_id;

  get diagnostics affected_rows = row_count;

  if affected_rows <> 1 then
    raise exception 'TEST FAILED: SUPER_ADMIN cannot deactivate ADMIN';
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
  run_token text := current_setting('nociblack_test.run_token');
  fixture_draft_item_id uuid :=
    current_setting('nociblack_test.fixture_draft_item_id')::uuid;
  rejection_detected boolean;
begin
  if public.is_active_admin() then
    raise exception 'TEST FAILED: inactive ADMIN retains ADMIN rights';
  end if;

  if exists (
    select 1
    from public.profiles
  ) then
    raise exception 'TEST FAILED: inactive ADMIN can read profiles';
  end if;

  -- Le brouillon est privé : sans droits ADMIN, il devient invisible.
  if exists (
    select 1
    from public.items
    where id = fixture_draft_item_id
  ) then
    raise exception 'TEST FAILED: inactive ADMIN can read draft items';
  end if;

  rejection_detected := false;

  begin
    insert into public.categories (name, slug)
    values (
      'Inactive ADMIN category',
      'inactive-admin-category-' || run_token
    );
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: inactive ADMIN can create categories';
  end if;
end;
$$;

reset role;
rollback;
