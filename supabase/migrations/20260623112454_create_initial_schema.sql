-- NociBlacK V1 - Initial database schema
--
-- This migration intentionally contains no RLS or Storage policy. RLS is
-- enabled at the end, which leaves every client access denied by default until
-- the dedicated policy migration is applied.

create extension if not exists pgcrypto with schema extensions;

create type public.admin_role as enum (
  'SUPER_ADMIN',
  'ADMIN'
);

create type public.item_status as enum (
  'DRAFT',
  'PUBLISHED',
  'ARCHIVED'
);

create table public.profiles (
  id uuid primary key references auth.users (id) on delete restrict,
  email text not null,
  role public.admin_role not null default 'ADMIN',
  first_name text,
  last_name text,
  is_active boolean not null default true,
  created_at timestamptz not null default statement_timestamp(),
  updated_at timestamptz not null default statement_timestamp(),

  constraint profiles_email_not_blank check (length(btrim(email)) > 0),
  constraint profiles_first_name_not_blank check (
    first_name is null or length(btrim(first_name)) > 0
  ),
  constraint profiles_last_name_not_blank check (
    last_name is null or length(btrim(last_name)) > 0
  )
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  description text,
  display_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default statement_timestamp(),
  updated_at timestamptz not null default statement_timestamp(),

  constraint categories_name_not_blank check (length(btrim(name)) > 0),
  constraint categories_slug_format check (
    slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'
  ),
  constraint categories_display_order_non_negative check (display_order >= 0)
);

create table public.items (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.categories (id) on delete restrict,
  title text not null,
  slug text not null,
  description text,
  price_cents integer not null,
  stock_quantity integer not null,
  sku text not null,
  status public.item_status not null default 'DRAFT',
  display_order integer not null default 0,
  created_at timestamptz not null default statement_timestamp(),
  updated_at timestamptz not null default statement_timestamp(),

  constraint items_title_not_blank check (length(btrim(title)) > 0),
  constraint items_slug_format check (
    slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'
  ),
  constraint items_price_cents_non_negative check (price_cents >= 0),
  constraint items_stock_quantity_non_negative check (stock_quantity >= 0),
  constraint items_sku_not_blank check (length(btrim(sku)) > 0),
  constraint items_display_order_non_negative check (display_order >= 0)
);

create table public.item_images (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references public.items (id) on delete restrict,
  image_url text not null,
  display_order integer not null,
  is_primary boolean not null default false,
  created_at timestamptz not null default statement_timestamp(),

  constraint item_images_image_url_not_blank check (
    length(btrim(image_url)) > 0
  ),
  constraint item_images_display_order_range check (
    display_order between 1 and 3
  ),
  constraint item_images_item_order_unique unique (item_id, display_order)
);

-- Functional indexes retain the desired display casing while enforcing
-- case-insensitive business uniqueness.
create unique index profiles_email_unique_ci
  on public.profiles (lower(email));

create unique index categories_name_unique_ci
  on public.categories (lower(name));

create unique index categories_slug_unique_ci
  on public.categories (lower(slug));

create index categories_active_order_idx
  on public.categories (is_active, display_order, created_at, id);

create unique index items_slug_unique_ci
  on public.items (lower(slug));

create unique index items_sku_unique_ci
  on public.items (lower(sku));

create index items_status_category_order_idx
  on public.items (status, category_id, display_order, created_at, id);

create index items_category_id_idx
  on public.items (category_id);

create unique index item_images_one_primary_per_item_idx
  on public.item_images (item_id)
  where is_primary;

-- Normalization is centralized in PostgreSQL so every future client follows
-- the same rules, independently of its own form validation.
create function public.normalize_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  auth_email text;
begin
  new.email := lower(btrim(new.email));
  new.first_name := nullif(btrim(new.first_name), '');
  new.last_name := nullif(btrim(new.last_name), '');

  select lower(btrim(users.email))
    into auth_email
    from auth.users
   where users.id = new.id;

  if auth_email is null then
    raise exception using
      errcode = '23514',
      message = 'A profile requires an Auth user with an email address.';
  end if;

  if new.email <> auth_email then
    raise exception using
      errcode = '23514',
      message = 'Profile email must match the Auth user email.';
  end if;

  return new;
end;
$$;

create function public.normalize_category()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.name := btrim(new.name);
  new.slug := lower(btrim(new.slug));
  new.description := nullif(btrim(new.description), '');
  return new;
end;
$$;

create function public.normalize_item()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.title := btrim(new.title);
  new.slug := lower(btrim(new.slug));
  new.description := nullif(btrim(new.description), '');
  new.sku := upper(btrim(new.sku));
  return new;
end;
$$;

create function public.normalize_item_image()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.image_url := btrim(new.image_url);
  return new;
end;
$$;

create trigger profiles_10_normalize
before insert or update on public.profiles
for each row execute function public.normalize_profile();

create trigger categories_10_normalize
before insert or update on public.categories
for each row execute function public.normalize_category();

create trigger items_10_normalize
before insert or update on public.items
for each row execute function public.normalize_item();

create trigger item_images_10_normalize
before insert or update on public.item_images
for each row execute function public.normalize_item_image();

-- Technical timestamps are owned by the database. created_at is immutable and
-- updated_at changes on every accepted business update.
create function public.maintain_update_timestamps()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.created_at is distinct from old.created_at then
    raise exception using
      errcode = '23514',
      message = format('%I.created_at is immutable.', tg_table_name);
  end if;

  new.updated_at := statement_timestamp();
  return new;
end;
$$;

create trigger profiles_20_maintain_timestamps
before update on public.profiles
for each row execute function public.maintain_update_timestamps();

create trigger categories_20_maintain_timestamps
before update on public.categories
for each row execute function public.maintain_update_timestamps();

create trigger items_20_maintain_timestamps
before update on public.items
for each row execute function public.maintain_update_timestamps();

create function public.prevent_created_at_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.created_at is distinct from old.created_at then
    raise exception using
      errcode = '23514',
      message = format('%I.created_at is immutable.', tg_table_name);
  end if;

  return new;
end;
$$;

create trigger item_images_20_preserve_created_at
before update on public.item_images
for each row execute function public.prevent_created_at_change();

-- Auth is the source of truth. This trigger updates an existing profile only;
-- it never provisions a new administrator automatically.
create function public.sync_existing_profile_email_from_auth()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.email is null and exists (
    select 1 from public.profiles where id = new.id
  ) then
    raise exception using
      errcode = '23514',
      message = 'An administrative Auth user must retain an email address.';
  end if;

  if new.email is distinct from old.email and new.email is not null then
    update public.profiles
       set email = lower(btrim(new.email))
     where id = new.id;
  end if;

  return new;
end;
$$;

create trigger auth_users_sync_existing_profile_email
after update of email on auth.users
for each row execute function public.sync_existing_profile_email_from_auth();

-- A published item must reference an active category and have between one and
-- three images, with exactly one primary image.
create function public.validate_item_before_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  category_is_active boolean;
  image_count integer;
  primary_image_count integer;
begin
  if tg_op = 'UPDATE'
     and old.status = 'ARCHIVED'
     and new.status <> old.status
     and new.status <> 'DRAFT' then
    raise exception using
      errcode = '23514',
      message = 'An archived item can only be restored to DRAFT.';
  end if;

  if new.status <> 'PUBLISHED' then
    return new;
  end if;

  select categories.is_active
    into category_is_active
    from public.categories
   where categories.id = new.category_id;

  if category_is_active is distinct from true then
    raise exception using
      errcode = '23514',
      message = 'A published item requires an active category.';
  end if;

  select count(*), count(*) filter (where item_images.is_primary)
    into image_count, primary_image_count
    from public.item_images
   where item_images.item_id = new.id;

  if image_count not between 1 and 3 then
    raise exception using
      errcode = '23514',
      message = 'A published item requires between one and three images.';
  end if;

  if primary_image_count <> 1 then
    raise exception using
      errcode = '23514',
      message = 'A published item requires exactly one primary image.';
  end if;

  return new;
end;
$$;

create trigger items_30_validate_business_rules
before insert or update on public.items
for each row execute function public.validate_item_before_write();

-- Locking the parent item serializes publication and image changes. The
-- constraint trigger is deferrable so a future transactional RPC can replace
-- the primary image atomically before validating the final state.
create function public.assert_published_item_images_valid(target_item_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_status public.item_status;
  image_count integer;
  primary_image_count integer;
begin
  select items.status
    into current_status
    from public.items
   where items.id = target_item_id
   for update;

  if current_status is distinct from 'PUBLISHED' then
    return;
  end if;

  select count(*), count(*) filter (where item_images.is_primary)
    into image_count, primary_image_count
    from public.item_images
   where item_images.item_id = target_item_id;

  if image_count not between 1 and 3 or primary_image_count <> 1 then
    raise exception using
      errcode = '23514',
      message = 'A published item requires one to three images and exactly one primary image.';
  end if;
end;
$$;

create function public.validate_published_item_after_image_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op in ('UPDATE', 'DELETE') then
    perform public.assert_published_item_images_valid(old.item_id);
  end if;

  if tg_op in ('INSERT', 'UPDATE')
     and (tg_op = 'INSERT' or new.item_id is distinct from old.item_id) then
    perform public.assert_published_item_images_valid(new.item_id);
  end if;

  return null;
end;
$$;

create constraint trigger item_images_validate_published_item
after insert or update or delete on public.item_images
deferrable initially immediate
for each row execute function public.validate_published_item_after_image_change();

-- Internal integrity functions must not become callable RPC endpoints through
-- the public schema. Their triggers continue to execute with their owner rights.
revoke all on function public.normalize_profile() from public;
revoke all on function public.normalize_category() from public;
revoke all on function public.normalize_item() from public;
revoke all on function public.normalize_item_image() from public;
revoke all on function public.maintain_update_timestamps() from public;
revoke all on function public.prevent_created_at_change() from public;
revoke all on function public.sync_existing_profile_email_from_auth() from public;
revoke all on function public.validate_item_before_write() from public;
revoke all on function public.assert_published_item_images_valid(uuid) from public;
revoke all on function public.validate_published_item_after_image_change() from public;

-- V1 uses logical deletion for these entities. Keeping this rule in the
-- database protects the model even if a future client contains a defect.
create function public.prevent_physical_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception using
    errcode = '23514',
    message = format(
      'Physical deletion from %I is forbidden. Use logical archiving instead.',
      tg_table_name
    );
end;
$$;

revoke all on function public.prevent_physical_delete() from public;

create trigger profiles_prevent_physical_delete
before delete on public.profiles
for each row execute function public.prevent_physical_delete();

create trigger categories_prevent_physical_delete
before delete on public.categories
for each row execute function public.prevent_physical_delete();

create trigger items_prevent_physical_delete
before delete on public.items
for each row execute function public.prevent_physical_delete();

comment on table public.profiles is
  'Administrative profiles linked one-to-one to Supabase Auth users.';
comment on table public.categories is
  'Dynamic catalogue categories; is_active=false represents logical archiving.';
comment on table public.items is
  'Catalogue items whose ARCHIVED status represents logical archiving.';
comment on table public.item_images is
  'Stable Supabase Storage object references associated with catalogue items.';
comment on column public.item_images.image_url is
  'Stable Storage object reference; never a temporary signed URL.';

-- Secure-by-default boundary. Policies are introduced in migration 2.
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.items enable row level security;
alter table public.item_images enable row level security;
