-- NociBlacK V1 - Initial schema regression test
-- Run the complete file from the Supabase SQL Editor. Every test executes in
-- one transaction and the final ROLLBACK guarantees that no catalogue fixture
-- is retained. Any failed expectation raises an exception and fails the run.
-- Profiles are intentionally excluded here: their integrity rules require an
-- existing Supabase Auth user and will be covered by dedicated Auth/RLS tests.

begin;

do $$
declare
  run_token text := replace(gen_random_uuid()::text, '-', '');
  active_category_id uuid;
  inactive_category_id uuid;
  nominal_item_id uuid;
  no_image_item_id uuid;
  inactive_category_item_id uuid;
  rejection_detected boolean;
  original_created_at timestamptz;
begin
  -- Secure-by-default boundary before the dedicated RLS migration
  if exists (
    select 1
      from pg_class as tables
      join pg_namespace as schemas on schemas.oid = tables.relnamespace
     where schemas.nspname = 'public'
       and tables.relname = any (array['profiles', 'categories', 'items', 'item_images'])
       and not tables.relrowsecurity
  ) then
    raise exception 'TEST FAILED: RLS is not enabled on every public table';
  end if;

  ---------------------------------------------------------------------------
  -- Nominal path and normalization
  ---------------------------------------------------------------------------
  insert into public.categories (
    name,
    slug,
    display_order
  )
  values (
    '  Test Active ' || run_token || '  ',
    '  TEST-ACTIVE-' || run_token || '  ',
    0
  )
  returning id into active_category_id;

  insert into public.categories (
    name,
    slug,
    is_active
  )
  values (
    'Test Inactive ' || run_token,
    'TEST-INACTIVE-' || run_token,
    false
  )
  returning id into inactive_category_id;

  if not exists (
    select 1
      from public.categories
     where id = active_category_id
       and name = 'Test Active ' || run_token
       and slug = 'test-active-' || run_token
  ) then
    raise exception 'TEST FAILED: category normalization';
  end if;

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
    '  Nominal Item  ',
    '  NOMINAL-ITEM-' || run_token || '  ',
    1500,
    0,
    '  test-' || run_token || '  '
  )
  returning id, created_at into nominal_item_id, original_created_at;

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    nominal_item_id,
    '  item-images/' || nominal_item_id || '/image_1.webp  ',
    1,
    true
  );

  update public.items
     set status = 'PUBLISHED'
   where id = nominal_item_id;

  if not exists (
    select 1
      from public.items
     where id = nominal_item_id
       and title = 'Nominal Item'
       and slug = 'nominal-item-' || run_token
       and sku = upper('test-' || run_token)
       and stock_quantity = 0
       and status = 'PUBLISHED'
  ) then
    raise exception 'TEST FAILED: nominal item publication or normalization';
  end if;

  if not exists (
    select 1
      from public.item_images
     where item_id = nominal_item_id
       and image_url = 'item-images/' || nominal_item_id || '/image_1.webp'
       and is_primary
  ) then
    raise exception 'TEST FAILED: image reference normalization';
  end if;

  ---------------------------------------------------------------------------
  -- Case-insensitive uniqueness
  ---------------------------------------------------------------------------
  rejection_detected := false;

  begin
    insert into public.categories (name, slug)
    values (
      lower('Test Active ' || run_token),
      'different-slug-' || run_token
    );
  exception
    when unique_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: case-insensitive category name uniqueness';
  end if;

  rejection_detected := false;

  begin
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
      'Duplicate SKU',
      'duplicate-sku-' || run_token,
      1000,
      1,
      lower('TEST-' || run_token)
    );
  exception
    when unique_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: case-insensitive SKU uniqueness';
  end if;

  ---------------------------------------------------------------------------
  -- Publication requirements
  ---------------------------------------------------------------------------
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
    'No Image Item',
    'no-image-' || run_token,
    1000,
    1,
    'NO-IMAGE-' || run_token
  )
  returning id into no_image_item_id;

  rejection_detected := false;

  begin
    update public.items
       set status = 'PUBLISHED'
     where id = no_image_item_id;
  exception
    when check_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: publication without image';
  end if;

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    no_image_item_id,
    'item-images/' || no_image_item_id || '/image_1.webp',
    1,
    false
  );

  rejection_detected := false;

  begin
    update public.items
       set status = 'PUBLISHED'
     where id = no_image_item_id;
  exception
    when check_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: publication without primary image';
  end if;

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
    'Inactive Category Item',
    'inactive-category-item-' || run_token,
    1000,
    1,
    'INACTIVE-' || run_token
  )
  returning id into inactive_category_item_id;

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values (
    inactive_category_item_id,
    'item-images/' || inactive_category_item_id || '/image_1.webp',
    1,
    true
  );

  rejection_detected := false;

  begin
    update public.items
       set status = 'PUBLISHED'
     where id = inactive_category_item_id;
  exception
    when check_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: publication in inactive category';
  end if;

  ---------------------------------------------------------------------------
  -- Image integrity
  ---------------------------------------------------------------------------
  rejection_detected := false;

  begin
    insert into public.item_images (
      item_id,
      image_url,
      display_order,
      is_primary
    )
    values (
      nominal_item_id,
      'item-images/' || nominal_item_id || '/image_2.webp',
      2,
      true
    );
  exception
    when unique_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: second primary image';
  end if;

  insert into public.item_images (
    item_id,
    image_url,
    display_order,
    is_primary
  )
  values
    (
      nominal_item_id,
      'item-images/' || nominal_item_id || '/image_2.webp',
      2,
      false
    ),
    (
      nominal_item_id,
      'item-images/' || nominal_item_id || '/image_3.webp',
      3,
      false
    );

  rejection_detected := false;

  begin
    insert into public.item_images (
      item_id,
      image_url,
      display_order,
      is_primary
    )
    values (
      nominal_item_id,
      'item-images/' || nominal_item_id || '/image_4.webp',
      4,
      false
    );
  exception
    when check_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: fourth image position';
  end if;

  rejection_detected := false;

  begin
    update public.item_images
       set is_primary = false
     where item_id = nominal_item_id
       and display_order = 1;
  exception
    when check_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: published item without primary image';
  end if;

  -- Physical deletion of a secondary image is allowed when the published item
  -- remains valid.
  delete from public.item_images
   where item_id = nominal_item_id
     and display_order = 3;

  if exists (
    select 1
      from public.item_images
     where item_id = nominal_item_id
       and display_order = 3
  ) then
    raise exception 'TEST FAILED: secondary image physical deletion';
  end if;

  ---------------------------------------------------------------------------
  -- Numeric, timestamp, lifecycle and logical-deletion rules
  ---------------------------------------------------------------------------
  rejection_detected := false;

  begin
    update public.items
       set stock_quantity = -1
     where id = nominal_item_id;
  exception
    when check_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: negative stock';
  end if;

  rejection_detected := false;

  begin
    update public.items
       set created_at = original_created_at - interval '1 day'
     where id = nominal_item_id;
  exception
    when check_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: mutable created_at';
  end if;

  -- Archiving a category is allowed and does not change its item statuses.
  update public.categories
     set is_active = false
   where id = active_category_id;

  if not exists (
    select 1
      from public.items
     where id = nominal_item_id
       and status = 'PUBLISHED'
  ) then
    raise exception 'TEST FAILED: category archive changed item status';
  end if;

  update public.categories
     set is_active = true
   where id = active_category_id;

  update public.items
     set status = 'ARCHIVED'
   where id = nominal_item_id;

  rejection_detected := false;

  begin
    update public.items
       set status = 'PUBLISHED'
     where id = nominal_item_id;
  exception
    when check_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: direct ARCHIVED to PUBLISHED transition';
  end if;

  rejection_detected := false;

  begin
    delete from public.categories
     where id = active_category_id;
  exception
    when check_violation then
      rejection_detected := true;
  end;

  if not rejection_detected then
    raise exception 'TEST FAILED: physical category deletion';
  end if;
end;
$$;

rollback;
