-- Add missing columns to jobs table
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS salary_min integer;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS salary_max integer;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS experience_level text;

-- Optional: Update existing rows with dummy data if needed
-- UPDATE jobs SET salary_min = 20000, salary_max = 30000 WHERE salary_min IS NULL;
