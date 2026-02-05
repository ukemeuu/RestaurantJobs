-- Create Saved Jobs Table
create table if not exists saved_jobs (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) not null,
  job_id uuid references jobs(id) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, job_id)
);

-- RLS Policies
alter table saved_jobs enable row level security;

create policy "Users can view their own saved jobs" on saved_jobs
  for select using (auth.uid() = user_id);

create policy "Users can insert their own saved jobs" on saved_jobs
  for insert with check (auth.uid() = user_id);

create policy "Users can delete their own saved jobs" on saved_jobs
  for delete using (auth.uid() = user_id);
