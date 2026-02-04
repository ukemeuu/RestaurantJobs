-- Create Candidate Profiles Table
create table if not exists candidate_profiles (
  id uuid references auth.users(id) primary key,
  resume_url text,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table candidate_profiles enable row level security;

-- RLS Policies
create policy "Candidates can view own profile" on candidate_profiles
  for select using (auth.uid() = id);

create policy "Candidates can update own profile" on candidate_profiles
  for update using (auth.uid() = id);

create policy "Candidates can insert own profile" on candidate_profiles
  for insert with check (auth.uid() = id);

-- Link applications to profiles (optional, but good for data integrity)
-- alter table applications add constraint fk_app_profile foreign key (candidate_id) references candidate_profiles(id);
