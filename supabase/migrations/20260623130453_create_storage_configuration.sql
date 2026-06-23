-- NociBlacK V1 - Supabase Storage configuration

-- Les images d’articles restent privées : leur lecture dépendra des politiques
-- liées au statut de l’article et à sa catégorie.
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
  2097152,
  array['image/webp']
)
on conflict (id) do update
set
  name = excluded.name,
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Les ressources de marque sont publiques, mais leur écriture restera réservée
-- au SUPER_ADMIN.
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'brand-assets',
  'brand-assets',
  true,
  2097152,
  array['image/png', 'image/webp']
)
on conflict (id) do update
set
  name = excluded.name,
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Une référence Storage doit correspondre exactement à l’article et à la
-- position enregistrés dans item_images.
alter table public.item_images
add constraint item_images_storage_path_matches_order
check (
  image_url = (
    'item-images/'
    || item_id::text
    || '/image_'
    || display_order::text
    || '.webp'
  )
);

-- Un même objet Storage ne peut être référencé qu’une seule fois.
create unique index item_images_image_url_unique
on public.item_images (image_url);

-- Les fonctions internes Storage restent hors du schéma public exposé par l’API.
create schema if not exists private;

revoke all on schema private from public;
grant usage on schema private to anon, authenticated;

-- Valide strictement le chemin interne au bucket :
-- {item_id}/image_{1..3}.webp
create function private.is_valid_item_image_object_name(object_name text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select object_name ~ (
    '^[0-9a-f]{8}-'
    || '[0-9a-f]{4}-'
    || '[0-9a-f]{4}-'
    || '[0-9a-f]{4}-'
    || '[0-9a-f]{12}/'
    || 'image_[1-3]\.webp$'
  );
$$;

revoke all
on function private.is_valid_item_image_object_name(text)
from public;

grant execute
on function private.is_valid_item_image_object_name(text)
to anon, authenticated;

-- Le public lit uniquement un objet référencé par un article publié dans une
-- catégorie active.
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

-- Un administrateur actif peut lire tous les objets du bucket, y compris les
-- fichiers orphelins qu’il faudrait nettoyer.
create policy item_images_storage_admin_read
on storage.objects
for select
to authenticated
using (
  bucket_id = 'item-images'
  and (select public.is_active_admin())
);

-- Un upload doit viser un article existant et respecter le chemin validé.
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
    where item.id::text = split_part(storage.objects.name, '/', 1)
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
    where item.id::text = split_part(storage.objects.name, '/', 1)
  )
);

-- La suppression est autorisée pour permettre le remplacement et le nettoyage.
create policy item_images_storage_admin_delete
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'item-images'
  and (select public.is_active_admin())
);

-- Les ressources de marque sont limitées au dossier public/ et utilisent des
-- noms déterministes en minuscules.
create function private.is_valid_brand_asset_object_name(object_name text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select object_name ~ '^public/[a-z0-9][a-z0-9_-]*\.(png|webp)$';
$$;

revoke all
on function private.is_valid_brand_asset_object_name(text)
from public;

grant execute
on function private.is_valid_brand_asset_object_name(text)
to anon, authenticated;

-- Cette politique autorise également la liste et le téléchargement via l’API
-- Storage. Le bucket public permet les URL publiques directes.
create policy brand_assets_storage_public_read
on storage.objects
for select
to anon, authenticated
using (
  bucket_id = 'brand-assets'
  and private.is_valid_brand_asset_object_name(name)
);

-- Seul un SUPER_ADMIN actif peut créer ou remplacer une ressource de marque.
create policy brand_assets_storage_super_admin_insert
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'brand-assets'
  and (select public.is_active_super_admin())
  and private.is_valid_brand_asset_object_name(name)
);

create policy brand_assets_storage_super_admin_update
on storage.objects
for update
to authenticated
using (
  bucket_id = 'brand-assets'
  and (select public.is_active_super_admin())
)
with check (
  bucket_id = 'brand-assets'
  and (select public.is_active_super_admin())
  and private.is_valid_brand_asset_object_name(name)
);

-- Le SUPER_ADMIN peut aussi nettoyer un éventuel objet invalide ou orphelin.
create policy brand_assets_storage_super_admin_delete
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'brand-assets'
  and (select public.is_active_super_admin())
);