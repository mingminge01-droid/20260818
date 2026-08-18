create table if not exists public.analysis_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  student_name text,
  college text,
  department text,
  entry_year integer,
  student_type text not null check (student_type in ('undergraduate', 'graduate')),
  result_data jsonb not null check (jsonb_typeof(result_data) = 'object'),
  created_at timestamptz not null default now()
);

alter table public.analysis_results enable row level security;

revoke all on table public.analysis_results from anon;
grant select, insert, delete on table public.analysis_results to authenticated;

drop policy if exists "Users can read their own analyses" on public.analysis_results;
create policy "Users can read their own analyses"
on public.analysis_results
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert their own analyses" on public.analysis_results;
create policy "Users can insert their own analyses"
on public.analysis_results
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete their own analyses" on public.analysis_results;
create policy "Users can delete their own analyses"
on public.analysis_results
for delete
to authenticated
using ((select auth.uid()) = user_id);

create index if not exists analysis_results_user_created_idx
on public.analysis_results (user_id, created_at desc);
