-- Add missing columns to jobs table to fix Post/Edit errors
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS salary_min integer;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS salary_max integer;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS experience_level text;

-- Ensure the jobs table allows updates (fixes 400 Bad Request if RLS denies it)
-- Note: Policies usually handle this, but columns must exist first.
