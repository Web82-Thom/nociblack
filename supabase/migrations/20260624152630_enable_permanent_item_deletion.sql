-- NociBlacK V1 - Permanent item deletion workflow
--
-- Physical deletion stays unavailable through direct table access. Active
-- ADMIN and SUPER_ADMIN sessions must use the dedicated RPC so every Storage
-- object is registered for durable cleanup before its database reference is
-- removed.

create table private.item_storage_deletion_jobs (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null,
  bucket_id text not null default 'item-images',
  object_name text not null,
  created_at timestamptz not null default statement_timestamp(),

  constraint item_storage_deletion_jobs_bucket_check check (
    bucket_id = 'item-images'
  ),
  constraint item_storage_deletion_jobs_object_name_not_blank check (
    length(btrim(object_name)) > 0
  ),
  constraint item_storage_deletion_jobs_object_unique unique (
    bucket_id,
    object_name
  )
);

revoke all on table private.item_storage_deletion_jobs
from public, anon, authenticated;

-- item_images belongs to the item aggregate. Once the object paths have been
-- queued, deleting the aggregate must remove every database reference in the
-- same PostgreSQL transaction.
alter table public.item_images
drop constraint item_images_item_id_fkey;

alter table public.item_images
add constraint item_images_item_id_fkey
foreign key (item_id)
references public.items (id)
on delete cascade;

-- Categories and profiles keep their physical-deletion protection. Items are
-- deleted only by the secured RPC below; direct authenticated DELETE remains
-- blocked because no table DELETE policy is created.
drop trigger items_prevent_physical_delete on public.items;

create function public.delete_item_permanently(target_item_id uuid)
returns table (
  job_id uuid,
  bucket_id text,
  object_name text
)
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_active_admin() then
    raise exception using
      errcode = '42501',
      message = 'Only an active ADMIN or SUPER_ADMIN can delete an item.';
  end if;

  perform 1
  from public.items as item
  where item.id = target_item_id
  for update;

  if not found then
    raise exception using
      errcode = 'P0002',
      message = 'Item not found.';
  end if;

  insert into private.item_storage_deletion_jobs (
    item_id,
    bucket_id,
    object_name
  )
  select
    image.item_id,
    'item-images',
    substr(image.image_url, length('item-images/') + 1)
  from public.item_images as image
  where image.item_id = target_item_id
  on conflict on constraint item_storage_deletion_jobs_object_unique do update
  set item_id = excluded.item_id;

  delete from public.items as item
  where item.id = target_item_id;

  return query
  select
    job.id,
    job.bucket_id,
    job.object_name
  from private.item_storage_deletion_jobs as job
  where job.item_id = target_item_id
  order by job.created_at, job.id;
end;
$$;

revoke all on function public.delete_item_permanently(uuid) from public;
grant execute on function public.delete_item_permanently(uuid) to authenticated;

-- The Flutter cleanup service uses this RPC to resume interrupted Storage
-- cleanup on the next authenticated administration session.
create function public.get_pending_item_storage_deletions(
  requested_limit integer default 50
)
returns table (
  job_id uuid,
  bucket_id text,
  object_name text
)
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_active_admin() then
    raise exception using
      errcode = '42501',
      message = 'Only an active ADMIN or SUPER_ADMIN can read cleanup jobs.';
  end if;

  return query
  select
    job.id,
    job.bucket_id,
    job.object_name
  from private.item_storage_deletion_jobs as job
  order by job.created_at, job.id
  limit least(greatest(coalesce(requested_limit, 50), 1), 100);
end;
$$;

revoke all on function public.get_pending_item_storage_deletions(integer)
from public;
grant execute on function public.get_pending_item_storage_deletions(integer)
to authenticated;

-- A job is acknowledged only after the Storage API confirms that the object
-- was removed (or was already absent). Stale jobs are intentionally harmless
-- and remain retryable.
create function public.complete_item_storage_deletions(completed_job_ids uuid[])
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_active_admin() then
    raise exception using
      errcode = '42501',
      message = 'Only an active ADMIN or SUPER_ADMIN can complete cleanup jobs.';
  end if;

  if completed_job_ids is null or cardinality(completed_job_ids) = 0 then
    return;
  end if;

  delete from private.item_storage_deletion_jobs as job
  where job.id = any(completed_job_ids);
end;
$$;

revoke all on function public.complete_item_storage_deletions(uuid[])
from public;
grant execute on function public.complete_item_storage_deletions(uuid[])
to authenticated;

comment on table private.item_storage_deletion_jobs is
  'Durable cleanup queue for item objects removed through the Storage API.';

comment on function public.delete_item_permanently(uuid) is
  'Deletes one item aggregate and returns its durable Storage cleanup jobs.';
