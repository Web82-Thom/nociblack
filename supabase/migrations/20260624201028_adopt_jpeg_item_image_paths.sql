-- NociBlacK V1 - JPEG item image architecture
--
-- Item images use immutable UUID-based object names. Their display order stays
-- in PostgreSQL and never participates in the Storage path.

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'item-images',
  'item-images',
  false,
  5242880,
  array['image/jpeg']
)
on conflict (id) do update
set
  name = excluded.name,
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Validates the object name inside the bucket:
-- items/{item_id}/{image_id}.jpg
create or replace function private.is_valid_item_image_object_name(
  object_name text
)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select coalesce(
    object_name ~ (
      '^items/'
      || '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-'
      || '[0-9a-f]{4}-[0-9a-f]{12}/'
      || '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-'
      || '[0-9a-f]{4}-[0-9a-f]{12}\.jpg$'
    ),
    false
  );
$$;

revoke all
on function private.is_valid_item_image_object_name(text)
from public;

grant execute
on function private.is_valid_item_image_object_name(text)
to anon, authenticated;

-- A WebP reference cannot be converted safely by relabelling its extension.
-- Abort explicitly if a legacy reference was introduced before this migration.
do $$
begin
  if exists (
    select 1
    from public.item_images as image
    where not (
      private.is_valid_item_image_object_name(
        substr(image.image_url, length('item-images/') + 1)
      )
      and split_part(image.image_url, '/', 3) = image.item_id::text
    )
  ) then
    raise exception using
      errcode = '23514',
      message = 'Legacy item images must be migrated before enabling JPEG paths.';
  end if;
end;
$$;

alter table public.item_images
drop constraint item_images_storage_path_matches_order;

alter table public.item_images
add constraint item_images_storage_path_matches_item
check (
  image_url like 'item-images/items/%'
  and private.is_valid_item_image_object_name(
    substr(image_url, length('item-images/') + 1)
  )
  and split_part(image_url, '/', 3) = item_id::text
);

-- is_primary remains in the V1 model, but it is derived from display_order:
-- the first image is always the primary image.
alter table public.item_images
add constraint item_images_primary_matches_first_position
check (is_primary = (display_order = 1));

-- Recreate the complete item-images policy set so this migration documents the
-- target authorization model without depending on historical definitions.
drop policy item_images_storage_public_read on storage.objects;
drop policy item_images_storage_admin_read on storage.objects;
drop policy item_images_storage_admin_insert on storage.objects;
drop policy item_images_storage_admin_update on storage.objects;
drop policy item_images_storage_admin_delete on storage.objects;

create policy item_images_storage_public_read
on storage.objects
for select
to anon, authenticated
using (
  bucket_id = 'item-images'
  and private.is_valid_item_image_object_name(name)
  and exists (
    select 1
    from public.item_images as image
    join public.items as item
      on item.id = image.item_id
    join public.categories as category
      on category.id = item.category_id
    where image.image_url = 'item-images/' || storage.objects.name
      and item.status = 'PUBLISHED'::public.item_status
      and category.is_active
  )
);

-- Administrators intentionally see malformed or orphaned objects so they can
-- diagnose and remove them.
create policy item_images_storage_admin_read
on storage.objects
for select
to authenticated
using (
  bucket_id = 'item-images'
  and (select public.is_active_admin())
);

create policy item_images_storage_admin_insert
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'item-images'
  and (select public.is_active_admin())
  and private.is_valid_item_image_object_name(name)
  and exists (
    select 1
    from public.items as item
    where item.id::text = split_part(storage.objects.name, '/', 2)
  )
);

create policy item_images_storage_admin_update
on storage.objects
for update
to authenticated
using (
  bucket_id = 'item-images'
  and (select public.is_active_admin())
)
with check (
  bucket_id = 'item-images'
  and (select public.is_active_admin())
  and private.is_valid_item_image_object_name(name)
  and exists (
    select 1
    from public.items as item
    where item.id::text = split_part(storage.objects.name, '/', 2)
  )
);

-- Deletion remains path-agnostic to support orphan cleanup and the durable
-- cleanup queue used by permanent item deletion.
create policy item_images_storage_admin_delete
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'item-images'
  and (select public.is_active_admin())
);

comment on function private.is_valid_item_image_object_name(text) is
  'Validates items/{item_id}/{image_id}.jpg object names in item-images.';

comment on constraint item_images_storage_path_matches_item
on public.item_images is
  'Ensures image_url uses the JPEG object owned by the referenced item.';

comment on constraint item_images_primary_matches_first_position
on public.item_images is
  'Keeps is_primary derived from display_order: position 1 is primary.';
