-- Create Applications Table
create table if not exists applications (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  name text not null,
  email text not null,
  phone text not null,
  location text not null,
  position text,
  desired_position text not null,
  experience text not null,
  cover_letter text not null,
  resume_url text not null,
  job_id uuid references jobs(id),
  status text default 'pending' check (status in ('pending', 'reviewing', 'shortlisted', 'rejected', 'hired'))
);

-- Enable RLS for Applications
alter table applications enable row level security;

-- Admins can view all applications
drop policy if exists "Admins can view all applications" on applications;
create policy "Admins can view all applications" on applications
  for select using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

-- Employers can view applications for their jobs
drop policy if exists "Employers can view applications for their jobs" on applications;
create policy "Employers can view applications for their jobs" on applications
  for select using (
    exists (
      select 1 from jobs 
      where jobs.id = applications.job_id 
      and jobs.employer_id = auth.uid()
    )
  );

-- Anyone can insert applications (public job applications)
drop policy if exists "Anyone can submit applications" on applications;
create policy "Anyone can submit applications" on applications
  for insert with check (true);

-- Admins can update applications
drop policy if exists "Admins can update applications" on applications;
create policy "Admins can update applications" on applications
  for update using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

-- Create index for faster queries
create index if not exists applications_job_id_idx on applications(job_id);
create index if not exists applications_status_idx on applications(status);
create index if not exists applications_created_at_idx on applications(created_at desc);
