-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create Jobs Table
create table jobs (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  title text not null,
  type text not null,
  location text not null,
  description text not null,
  employer_id uuid references auth.users(id),
  source text default 'employer', -- 'employer' or 'internal'
  status text default 'published',
  salary_min integer,
  salary_max integer,
  experience_level text -- 'Entry', 'Mid', 'Senior', 'Executive'
);

-- Access policies for Jobs
alter table jobs enable row level security;
create policy "Public jobs are viewable by everyone" on jobs
  for select using (true);
create policy "Employers can insert their own jobs" on jobs
  for insert with check (auth.uid() = employer_id);
create policy "Employers can update their own jobs" on jobs
  for update using (auth.uid() = employer_id);

-- Create Employers Profile Table
create table employers (
  id uuid references auth.users(id) primary key,
  org_name text,
  branches text,
  staff_count text,
  poc_name text,
  poc_email text,
  poc_phone text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Access policies for Employers
alter table employers enable row level security;
create policy "Employers can view their own profile" on employers
  for select using (auth.uid() = id);
create policy "Employers can update their own profile" on employers
  for update using (auth.uid() = id);
create policy "Employers can insert their own profile" on employers
  for insert with check (true);

-- Create Applications Table
create table applications (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  job_id uuid references jobs(id),
  name text not null,
  email text not null,
  position text not null,
  reason text,
  resume_url text,
  status text default 'new'
);

-- Access policies for Applications
alter table applications enable row level security;
create policy "Anyone can submit an application" on applications
  for insert with check (true);
create policy "Employers can view applications for their jobs" on applications
  for select using (
    exists (
      select 1 from jobs
      where jobs.id = applications.job_id
      and jobs.employer_id = auth.uid()
    )
  );

-- Create Hiring Requests Table (Agency)
create table hiring_requests (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  employer_id uuid references auth.users(id),
  title text not null,
  type text,
  duration text,
  salary text,
  experience_level text,
  start_date text,
  org_name text,
  contact_name text,
  contact_email text,
  contact_phone text,
  status text default 'new_lead'
);

-- Access policies for Hiring Requests
alter table hiring_requests enable row level security;
create policy "Employers can view their own requests" on hiring_requests
  for select using (auth.uid() = employer_id);
create policy "Everyone can insert requests" on hiring_requests
  for insert with check (true);

-- Storage bucket for resumes
insert into storage.buckets (id, name, public)
values ('resumes', 'resumes', true)
on conflict (id) do nothing;

-- Storage Policies
-- Allow public access to view files in the 'resumes' bucket
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'resumes' );

-- Allow anyone to upload to the 'resumes' bucket
create policy "Public Upload"
  on storage.objects for insert
  with check ( bucket_id = 'resumes' );

-- User Roles Table (Unified Auth)
create table user_roles (
  id uuid references auth.users(id) primary key,
  role text not null check (role in ('admin', 'employer', 'candidate')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Access policies for User Roles
alter table user_roles enable row level security;
create policy "Users can read own role" on user_roles for select using (auth.uid() = id);
create policy "Users can insert own role" on user_roles for insert with check (auth.uid() = id);

-- Update Applications Table to track Candidate
alter table applications add column candidate_id uuid references auth.users(id);

-- STRICTER RLS POLICIES (Re-defining for clarity)
-- Jobs: Only Admin can insert. Public can view.
drop policy if exists "Employers can insert their own jobs" on jobs;
create policy "Admins and Employers can insert jobs" on jobs
  for insert with check (
    exists (select 1 from user_roles where id = auth.uid() and role in ('admin', 'employer'))
  );

-- Hiring Requests: Employers can insert.
create policy "Employers can insert requests" on hiring_requests
  for insert with check (
    exists (select 1 from user_roles where id = auth.uid() and role = 'employer')
  );

-- Applications: Candidates can insert.
drop policy if exists "Anyone can submit an application" on applications;
create policy "Candidates can submit applications" on applications
  for insert with check (
    exists (select 1 from user_roles where id = auth.uid() and role = 'candidate')
  );
  
create policy "Candidates can view own applications" on applications
  for select using (auth.uid() = candidate_id);
