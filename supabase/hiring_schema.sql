-- Create Hiring Requests Table (Leads)
create table if not exists hiring_requests (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  -- Job Details
  title text not null,
  description text not null,
  duration text,
  salary text,
  experience_level text,
  start_date text,
  
  -- Organization / Contact
  org_name text not null,
  contact_name text not null,
  contact_email text not null,
  contact_phone text not null,
  
  -- Monetization (New Columns)
  plan_tier text default 'standard', -- standard, pro, premium
  amount_due integer default 0,
  add_ons jsonb default '[]'::jsonb, -- Array of selected addons e.g. ["urgent", "sms_blast"]
  
  -- Status
  status text default 'new_lead', -- new_lead, contacted, invoiced, paid, published
  notes text
);

-- RLS
alter table hiring_requests enable row level security;

-- Public (Unauthenticated) can insert (Lead Gen)
drop policy if exists "Anyone can insert hiring requests" on hiring_requests;
create policy "Anyone can insert hiring requests" on hiring_requests
  for insert with check (true);

-- Only Admin can view/update
drop policy if exists "Admins can view hiring requests" on hiring_requests;
create policy "Admins can view hiring requests" on hiring_requests
  for select using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

drop policy if exists "Admins can update hiring requests" on hiring_requests;
create policy "Admins can update hiring requests" on hiring_requests
  for update using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );
