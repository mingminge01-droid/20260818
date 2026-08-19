create table if not exists public.analysis_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  student_name text not null default '익명',
  college text,
  department text,
  entry_year integer,
  academic_year integer check (academic_year between 1 and 20),
  enrolled_credits numeric(6,1) not null default 0 check (enrolled_credits >= 0),
  student_type text not null check (student_type in ('undergraduate', 'graduate')),
  result_data jsonb not null check (jsonb_typeof(result_data) = 'object'),
  created_at timestamptz not null default now()
);

alter table public.analysis_results
  add column if not exists academic_year integer check (academic_year between 1 and 20),
  add column if not exists enrolled_credits numeric(6,1) not null default 0 check (enrolled_credits >= 0);

update public.analysis_results
set
  entry_year = coalesce(
    entry_year,
    (substring(result_data ->> 'profile' from '([0-9]{4})학번'))::integer
  ),
  enrolled_credits = case
    when (result_data ->> 'enrolled') ~ '^[0-9]+(\.[0-9]+)?$'
      then (result_data ->> 'enrolled')::numeric
    else enrolled_credits
  end,
  academic_year = coalesce(
    academic_year,
    (
      select ceil((substring(requirement ->> 'detail' from '([0-9]+)학기'))::numeric / 2)::integer
      from jsonb_array_elements(coalesce(result_data -> 'requirements', '[]'::jsonb)) as requirement
      where requirement ->> 'name' in ('등록 및 수업이수학기', '정규등록')
        and requirement ->> 'detail' ~ '[0-9]+학기'
      limit 1
    )
  );

update public.analysis_results
set student_name = case
  when student_name is null or btrim(student_name) = '' then '익명'
  when btrim(student_name) = '익명' then '익명'
  when char_length(btrim(student_name)) = 1 then '*'
  when char_length(btrim(student_name)) = 2 then left(btrim(student_name), 1) || '*'
  else left(btrim(student_name), 1)
    || repeat('*', char_length(btrim(student_name)) - 2)
    || right(btrim(student_name), 1)
end
where student_name is distinct from '익명';

alter table public.analysis_results
  alter column student_name set default '익명',
  alter column student_name set not null;

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
