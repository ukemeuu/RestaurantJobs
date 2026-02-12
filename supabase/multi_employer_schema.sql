-- 1. Create Employers Table (Idempotent)
create table if not exists public.employers (
  id uuid references auth.users(id) primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Safely add columns if they don't exist
do $$ 
begin
    if not exists (select 1 from information_schema.columns where table_name='employers' and column_name='company_name') then
        alter table public.employers add column company_name text;
    end if;

    if not exists (select 1 from information_schema.columns where table_name='employers' and column_name='logo_url') then
        alter table public.employers add column logo_url text;
    end if;

    if not exists (select 1 from information_schema.columns where table_name='employers' and column_name='website') then
        alter table public.employers add column website text;
    end if;

    if not exists (select 1 from information_schema.columns where table_name='employers' and column_name='is_verified') then
        alter table public.employers add column is_verified boolean default false;
    end if;

    if not exists (select 1 from information_schema.columns where table_name='employers' and column_name='subscription_status') then
        alter table public.employers add column subscription_status text default 'free';
    end if;
end $$;

-- Enable RLS on employers
alter table public.employers enable row level security;

-- Employers can read their own profile
drop policy if exists "Employers can view own profile" on employers;
create policy "Employers can view own profile" on employers
  for select using (auth.uid() = id);

-- Employers can update their own profile
drop policy if exists "Employers can update own profile" on employers;
create policy "Employers can update own profile" on employers
  for update using (auth.uid() = id);

-- Admins can view/update all employers
drop policy if exists "Admins can view all employers" on employers;
create policy "Admins can view all employers" on employers
  for select using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

drop policy if exists "Admins can update all employers" on employers;
create policy "Admins can update all employers" on employers
  for update using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

-- Public can view Verified Employers (for profile pages)
drop policy if exists "Public can view verified employers" on employers;
create policy "Public can view verified employers" on employers
  for select using (is_verified = true);


-- 2. Update Jobs Table (Idempotent)
do $$ 
begin
    if not exists (select 1 from information_schema.columns where table_name='jobs' and column_name='employer_id') then
        alter table public.jobs add column employer_id uuid references auth.users(id);
    end if;

    if not exists (select 1 from information_schema.columns where table_name='jobs' and column_name='status') then
        alter table public.jobs add column status text default 'pending';
    end if;
end $$;

-- Add check constraint for status
alter table public.jobs drop constraint if exists jobs_status_check;
alter table public.jobs add constraint jobs_status_check check (status in ('pending', 'approved', 'rejected', 'closed', 'published')); 

-- Update existing jobs to have an employer (if null, assign to current user or admin logic needed in application code)
-- For now, leave null, but RLS might hide them if we're strict.
-- Let's make existing jobs 'approved' by default.
update public.jobs set status = 'approved' where status = 'published' or status is null;


-- 3. Update Jobs RLS
-- Public Read: Only Approved jobs
drop policy if exists "Public jobs are viewable by everyone" on jobs;
create policy "Public jobs are viewable by everyone" on jobs
  for select using (status = 'approved' or status = 'published');

-- Employer Read: Own jobs (any status)
drop policy if exists "Employers can view own jobs" on jobs;
create policy "Employers can view own jobs" on jobs
  for select using (auth.uid() = employer_id);

-- Employer Insert: Their own jobs
drop policy if exists "Employers can insert own jobs" on jobs;
create policy "Employers can insert own jobs" on jobs
  for insert with check (auth.uid() = employer_id); 
  -- Note: Application code must set employer_id = auth.uid()

-- Employer Update: Own jobs
drop policy if exists "Employers can update own jobs" on jobs;
create policy "Employers can update own jobs" on jobs
  for update using (auth.uid() = employer_id);

-- Admin: Full Access
drop policy if exists "Admins have full access to jobs" on jobs;
create policy "Admins have full access to jobs" on jobs
  for all using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );


-- 4. Update Applications RLS
-- Only the JOB OWNER (Employer) or Admin can view applications for a job

drop policy if exists "Job owners can view applications" on applications;
create policy "Job owners can view applications" on applications
  for select using (
    exists (
      select 1 from jobs
      where jobs.id = applications.job_id
      and jobs.employer_id = auth.uid()
    )
  );

-- Admins view all applications
drop policy if exists "Admins can view all applications" on applications;
create policy "Admins can view all applications" on applications
  for select using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );


-- 5. Storage for Logos
-- Ensure 'logos' bucket exists (run in dashboard or via client, but policy here)
insert into storage.buckets (id, name, public) values ('logos', 'logos', true) on conflict (id) do nothing;

-- Allow authenticated users to upload logos
drop policy if exists "Authenticated users can upload logos" on storage.objects;
create policy "Authenticated users can upload logos" on storage.objects
  for insert with check (
    bucket_id = 'logos' and auth.role() = 'authenticated'
  );

-- Make logos public
drop policy if exists "Logos are public" on storage.objects;
create policy "Logos are public" on storage.objects
  for select using (bucket_id = 'logos');
