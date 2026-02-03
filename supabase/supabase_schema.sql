-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create Jobs Table
create table if not exists jobs (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  title text not null,
  type text not null,
  location text not null,
  description text not null,
  employer_id uuid references auth.users(id),
  source text default 'employer', -- 'employer' or 'internal'
  status text default 'published',
  logo_url text,
  salary_min integer,
  salary_max integer,
  experience_level text
);

-- Access policies for Jobs
alter table jobs enable row level security;

-- VIEW: Public
drop policy if exists "Public jobs are viewable by everyone" on jobs;
create policy "Public jobs are viewable by everyone" on jobs
  for select using (true);

-- INSERT: Admin & Employer
drop policy if exists "Admins and Employers can insert jobs" on jobs;
create policy "Admins and Employers can insert jobs" on jobs
  for insert with check (
    exists (select 1 from user_roles where id = auth.uid() and role in ('admin', 'employer'))
  );

-- UPDATE: Employer (Own) & Admin
drop policy if exists "Employers can update their own jobs" on jobs;
create policy "Employers can update their own jobs" on jobs
  for update using (
    auth.uid() = employer_id 
    OR 
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

-- DELETE: Employer (Own) & Admin
drop policy if exists "Employers and Admins can delete jobs" on jobs;
create policy "Employers and Admins can delete jobs" on jobs
  for delete using (
    auth.uid() = employer_id 
    OR 
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

-- ... (Rest of tables: employers, applications, hiring_requests) - leaving as is helps, but I'll add the User Roles table definition to be safe if this is run as full schema
-- But to avoid overwriting data if user runs this, 'if not exists' is key.
-- However, RLS policies can be dropped and recreated safely.

-- Ensure User Roles Table exists (Crucial for the above policies)
create table if not exists user_roles (
  id uuid references auth.users(id) primary key,
  role text not null check (role in ('admin', 'employer', 'candidate')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table user_roles enable row level security;
drop policy if exists "Users can read own role" on user_roles;
create policy "Users can read own role" on user_roles for select using (auth.uid() = id);
-- Allow Admin to read all roles? Ideally yes.
create policy "Admins can read all roles" on user_roles for select using (
    exists (select 1 from user_roles ur where ur.id = auth.uid() and ur.role = 'admin')
);

-- Storage Policies (Resumes)
insert into storage.buckets (id, name, public) values ('resumes', 'resumes', true) on conflict (id) do nothing;
-- Policies for storage need to be run in SQL editor, can't easily script "drop policy if exists" for storage in standard SQL file without plpgsql sometimes, but let's try standard.
-- Note: User needs to run this in Supabase SQL Editor.
