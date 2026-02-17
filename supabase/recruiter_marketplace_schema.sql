-- 1. Update User Roles Limit (Add 'recruiter')
-- We need to drop the existing check constraint and add a new one
alter table public.user_roles drop constraint if exists user_roles_role_check;
alter table public.user_roles add constraint user_roles_role_check check (role in ('admin', 'employer', 'candidate', 'recruiter'));

-- 2. Create Recruiter Profiles Table
create table if not exists public.recruiter_profiles (
  id uuid references auth.users(id) primary key,
  agency_name text not null,
  logo_url text,
  phone text,
  website text,
  is_verified boolean default false,
  subscription_status text default 'inactive' check (subscription_status in ('active', 'inactive', 'past_due')),
  subscription_end_date timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Enable RLS
alter table public.recruiter_profiles enable row level security;

-- Policies for Recruiter Profiles
-- Recruiters can view/update their own profile
drop policy if exists "Recruiters can view own profile" on recruiter_profiles;
create policy "Recruiters can view own profile" on recruiter_profiles
  for select using (auth.uid() = id);

drop policy if exists "Recruiters can update own profile" on recruiter_profiles;
create policy "Recruiters can update own profile" on recruiter_profiles
  for update using (auth.uid() = id);

-- Admins can view/update all recruiter profiles
drop policy if exists "Admins can view all recruiter profiles" on recruiter_profiles;
create policy "Admins can view all recruiter profiles" on recruiter_profiles
  for select using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

drop policy if exists "Admins can update all recruiter profiles" on recruiter_profiles;
create policy "Admins can update all recruiter profiles" on recruiter_profiles
  for update using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

-- Public can view Verified Recruiters (for future directory)
drop policy if exists "Public can view verified recruiters" on recruiter_profiles;
create policy "Public can view verified recruiters" on recruiter_profiles
  for select using (is_verified = true);


-- 4. Update Jobs Policies to allow Recruiters to Post
-- We modify existing policies to include 'recruiter' role

-- INSERT: Admins, Employers, AND Recruiters
drop policy if exists "Admins and Employers can insert jobs" on jobs; -- Drop old name
drop policy if exists "Authorized users can insert jobs" on jobs;
create policy "Authorized users can insert jobs" on jobs
  for insert with check (
    exists (select 1 from user_roles where id = auth.uid() and role in ('admin', 'employer', 'recruiter'))
  );

-- UPDATE: Own Jobs (Employer OR Recruiter) & Admin
drop policy if exists "Employers can update their own jobs" on jobs; -- Drop old name
drop policy if exists "Owners can update own jobs" on jobs;
create policy "Owners can update own jobs" on jobs
  for update using (
    auth.uid() = employer_id 
    OR 
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

-- DELETE: Own Jobs & Admin
drop policy if exists "Employers and Admins can delete jobs" on jobs; -- Drop old name
drop policy if exists "Owners can delete own jobs" on jobs;
create policy "Owners can delete own jobs" on jobs
  for delete using (
    auth.uid() = employer_id 
    OR 
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );


-- 5. Helper Function to handle new user registration (Optional Trigger Update)
-- You might need to update your handle_new_user trigger if it automatically assigns roles.
-- For now, we assume role assignment happens via the client-side logic or specific sign-up flow.
