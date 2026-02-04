-- Add add_ons column to hiring_requests table
alter table hiring_requests 
add column if not exists add_ons jsonb default '[]'::jsonb;
