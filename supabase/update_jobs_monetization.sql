-- Add monetization columns to jobs table
alter table jobs 
add column if not exists is_paid boolean default false,
add column if not exists features jsonb default '{}'::jsonb,
add column if not exists payment_ref text,
add column if not exists sticky_until timestamp with time zone;

-- Update RLS policies to allow updating these columns (if needed, though existing update policy might cover it if using service role or proper checks)
-- Ideally, these should only be updatable by admin or system, but for now we rely on the backend/edge function to handle payment verification and update these.
-- OR if we are doing client-side trusted updates (NOT RECOMMENDED for production but maybe for this MVP phase if no backend), we might need to allow it.
-- For this MVP, we'll assume the client sends this data during insert/update, and we trust it (or will add a backend verification later).

-- Index for sticky posts sorting
create index if not exists idx_jobs_sticky on jobs (sticky_until desc nulls last, created_at desc);
