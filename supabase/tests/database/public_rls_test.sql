-- NociBlacK V1 - Public RLS regression test
-- Fixtures are created as postgres, then assertions run as the real anon role.

begin;

do $$
declare
  run_token text := replace(gen_random_uuid()::text, '-', '');
  active_category_id uuid;
  inactive_category_id uuid;
  public_item_id uuid;
  draft_item_id uuid;
  hidden_item_id uuid;
  public_image_id uuid;
  draft_image_id uuid;
  hidden_image_id uuid;
begin
  -- Création des données temporaires avec le rôle propriétaire.
  insert into public.categories (name, slug)
  values (
    'Public category ' || run_token,
    'public-category-' || run_token
  )
  returning id into active_category_id;

  insert into public.categories (name, slug)
  values (
    'Inactive category ' || run_token,
    'inactive-category-' || run_token
  )
  returning id into inactive_category_id;

  insert into public.items (
    category_id,
    title,
    slug,
    price_cents,
    stock_quantity,
    sku
  )
  values (
    active_category_id,
    'Public item',
    'public-item-' || run_token,
    1000,
    1,
    'PUBLIC-' || run_token
  )
  returning id into public_item_id;

  insert into public.items (
    category_id,
    title,
    slug,
    price_cents,
    stock_quantity,
    sku
  )
  values (
    active_category_id,
    'Draft item',
    'draft-item-' || run_token,
    1000,
    1,
    'DRAFT-' || run_token
  )
  returning id into draft_item_id;

  insert into public.items (
    category_id,
    title,
    slug,
    price_cents,
    stock_quantity,
    sku
  )
  values (
    inactive_category_id,
    'Hidden item',
    'hidden-item-' || run_token,
    1000,
    1,
    'HIDDEN-' || run_token
  )
  returning id into hidden_item_id;

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    public_item_id,
    'item-images/' || public_item_id || '/image_1.webp',
    1,
    true
  )
  returning id into public_image_id;

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    draft_item_id,
    'item-images/' || draft_item_id || '/image_1.webp',
    1,
    true
  )
  returning id into draft_image_id;

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    hidden_item_id,
    'item-images/' || hidden_item_id || '/image_1.webp',
    1,
    true
  )
  returning id into hidden_image_id;

  update public.items
  set status = 'PUBLISHED'
  where id in (public_item_id, hidden_item_id);

  -- Une catégorie peut être archivée après la publication de ses articles.
  update public.categories
  set is_active = false
  where id = inactive_category_id;

  -- Les identifiants sont conservés dans la transaction pour le bloc anon.
  perform set_config(
    'nociblack_test.active_category_id',
    active_category_id::text,
    true
  );

  perform set_config(
    'nociblack_test.inactive_category_id',
    inactive_category_id::text,
    true
  );

  perform set_config(
    'nociblack_test.public_item_id',
    public_item_id::text,
    true
  );

  perform set_config(
    'nociblack_test.draft_item_id',
    draft_item_id::text,
    true
  );

  perform set_config(
    'nociblack_test.hidden_item_id',
    hidden_item_id::text,
    true
  );

  perform set_config(
    'nociblack_test.public_image_id',
    public_image_id::text,
    true
  );

  perform set_config(
    'nociblack_test.draft_image_id',
    draft_image_id::text,
    true
  );

  perform set_config(
    'nociblack_test.hidden_image_id',
    hidden_image_id::text,
    true
  );
end;
$$;

-- Toutes les requêtes suivantes utilisent réellement le rôle public Supabase.
set local role anon;

do $$
declare
  active_category_id uuid :=
    current_setting('nociblack_test.active_category_id')::uuid;
  inactive_category_id uuid :=
    current_setting('nociblack_test.inactive_category_id')::uuid;
  public_item_id uuid :=
    current_setting('nociblack_test.public_item_id')::uuid;
  draft_item_id uuid :=
    current_setting('nociblack_test.draft_item_id')::uuid;
  hidden_item_id uuid :=
    current_setting('nociblack_test.hidden_item_id')::uuid;
  public_image_id uuid :=
    current_setting('nociblack_test.public_image_id')::uuid;
  draft_image_id uuid :=
    current_setting('nociblack_test.draft_image_id')::uuid;
  hidden_image_id uuid :=
    current_setting('nociblack_test.hidden_image_id')::uuid;
  rejection_detected boolean;
begin
  -- Une catégorie active est publique.
  if not exists (
    select 1
    from public.categories
    where id = active_category_id
  ) then
    raise exception 'TEST FAILED: active category is not public';
  end if;

  -- Une catégorie inactive est masquée.
  if exists (
    select 1
    from public.categories
    where id = inactive_category_id
  ) then
    raise exception 'TEST FAILED: inactive category is public';
  end if;

  -- Seul l’article publié dans une catégorie active est public.
  if not exists (
    select 1
    from public.items
    where id = public_item_id
  ) then
    raise exception 'TEST FAILED: published item is not public';
  end if;

  if exists (
    select 1
    from public.items
    where id in (draft_item_id, hidden_item_id)
  ) then
    raise exception 'TEST FAILED: hidden item is public';
  end if;

  -- Les images suivent exactement la visibilité de leur article.
  if not exists (
    select 1
    from public.item_images
    where id = public_image_id
  ) then
    raise exception 'TEST FAILED: public image is not visible';
  end if;

  if exists (
    select 1
    from public.item_images
    where id in (draft_image_id, hidden_image_id)
  ) then
    raise exception 'TEST FAILED: private image is public';
  end if;

  -- Le rôle anon ne possède aucun accès aux profils.
  rejection_detected := false;

  begin
    perform 1
    from public.profiles
    limit 1;
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: anon can read profiles';
  end if;

  -- Le rôle anon ne peut créer aucune catégorie.
  rejection_detected := false;

  begin
    insert into public.categories (name, slug)
    values ('Forbidden category', 'forbidden-category');
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: anon can insert categories';
  end if;

  -- Le rôle anon ne peut modifier aucun article.
  rejection_detected := false;

  begin
    update public.items
    set stock_quantity = 0
    where id = public_item_id;
  exception
    when insufficient_privilege then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: anon can update items';
  end if;
end;
$$;

reset role;
rollback;