-- NociBlacK V1 - Row Level Security policies

-- Vérifie que la session appartient à un administrateur actif.
-- SUPER_ADMIN possède également les droits métier d’un ADMIN.
create function public.is_active_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles as profile
    where profile.id = (select auth.uid())
      and profile.is_active
      and profile.role in (
        'ADMIN'::public.admin_role,
        'SUPER_ADMIN'::public.admin_role
      )
  );
$$;

-- Vérifie que la session appartient à un SUPER_ADMIN actif.
create function public.is_active_super_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles as profile
    where profile.id = (select auth.uid())
      and profile.is_active
      and profile.role = 'SUPER_ADMIN'::public.admin_role
  );
$$;

-- Ces fonctions sont internes aux politiques RLS.
revoke all on function public.is_active_admin() from public;
revoke all on function public.is_active_super_admin() from public;

grant execute on function public.is_active_admin() to authenticated;
grant execute on function public.is_active_super_admin() to authenticated;

-- Une catégorie publique doit être active.
create policy categories_public_read
on public.categories
for select
to anon, authenticated
using (is_active);

-- Un article public doit être publié et appartenir à une catégorie active.
create policy items_public_read
on public.items
for select
to anon, authenticated
using (
  status = 'PUBLISHED'::public.item_status
  and exists (
    select 1
    from public.categories as category
    where category.id = items.category_id
      and category.is_active
  )
);

-- Une image publique suit la visibilité de son article et de sa catégorie.
create policy item_images_public_read
on public.item_images
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.items as item
    join public.categories as category
      on category.id = item.category_id
    where item.id = item_images.item_id
      and item.status = 'PUBLISHED'::public.item_status
      and category.is_active
  )
);

-- Les administrateurs actifs peuvent consulter toutes les catégories.
create policy categories_admin_read
on public.categories
for select
to authenticated
using ((select public.is_active_admin()));

create policy categories_admin_insert
on public.categories
for insert
to authenticated
with check ((select public.is_active_admin()));

create policy categories_admin_update
on public.categories
for update
to authenticated
using ((select public.is_active_admin()))
with check ((select public.is_active_admin()));

-- Les administrateurs actifs peuvent consulter et gérer tous les articles.
create policy items_admin_read
on public.items
for select
to authenticated
using ((select public.is_active_admin()));

create policy items_admin_insert
on public.items
for insert
to authenticated
with check ((select public.is_active_admin()));

create policy items_admin_update
on public.items
for update
to authenticated
using ((select public.is_active_admin()))
with check ((select public.is_active_admin()));

-- Les images peuvent être supprimées physiquement, contrairement aux
-- catégories et aux articles qui utilisent uniquement l’archivage logique.
create policy item_images_admin_read
on public.item_images
for select
to authenticated
using ((select public.is_active_admin()));

create policy item_images_admin_insert
on public.item_images
for insert
to authenticated
with check ((select public.is_active_admin()));

create policy item_images_admin_update
on public.item_images
for update
to authenticated
using ((select public.is_active_admin()))
with check ((select public.is_active_admin()));

create policy item_images_admin_delete
on public.item_images
for delete
to authenticated
using ((select public.is_active_admin()));

-- Un administrateur actif peut uniquement consulter son propre profil.
create policy profiles_admin_read_own
on public.profiles
for select
to authenticated
using (
  id = (select auth.uid())
  and (select public.is_active_admin())
);

-- Un SUPER_ADMIN actif peut consulter et gérer tous les profils.
create policy profiles_super_admin_read
on public.profiles
for select
to authenticated
using ((select public.is_active_super_admin()));

create policy profiles_super_admin_insert
on public.profiles
for insert
to authenticated
with check ((select public.is_active_super_admin()));

create policy profiles_super_admin_update
on public.profiles
for update
to authenticated
using ((select public.is_active_super_admin()))
with check ((select public.is_active_super_admin()));

-- Les privilèges SQL et les politiques RLS sont deux protections distinctes.
-- Une opération doit être autorisée par les deux niveaux.
revoke all on table public.profiles from public, anon, authenticated;
revoke all on table public.categories from public, anon, authenticated;
revoke all on table public.items from public, anon, authenticated;
revoke all on table public.item_images from public, anon, authenticated;

grant usage on schema public to anon, authenticated;
grant usage on type public.admin_role to authenticated;
grant usage on type public.item_status to anon, authenticated;

grant select
on table public.categories, public.items, public.item_images
to anon;

grant select
on table public.profiles, public.categories, public.items, public.item_images
to authenticated;

grant insert, update
on table public.profiles, public.categories, public.items
to authenticated;

grant insert, update, delete
on table public.item_images
to authenticated;