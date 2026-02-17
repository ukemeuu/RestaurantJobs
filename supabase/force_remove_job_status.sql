-- FORCE REMOVE JOB STATUS CONSTRAINTS
-- We are getting constraint violations despite adding valid values.
-- This script will attempt to clean up ALL related constraints.

-- 1. Drop known constraints
ALTER TABLE jobs DROP CONSTRAINT IF EXISTS jobs_status_check;
ALTER TABLE jobs DROP CONSTRAINT IF EXISTS jobs_status_check_final;
ALTER TABLE jobs DROP CONSTRAINT IF EXISTS check_status;

-- 2. Drop the constraint by finding it dynamically (if possible in your mental model, but here straightforward)
-- We will just re-add the "final" one with even looser rules to be safe.

-- 3. Add the definitive constraint
-- Note: usage of lowercase is standard.
ALTER TABLE jobs
ADD CONSTRAINT jobs_status_check_final
CHECK (status IN ('pending', 'approved', 'rejected', 'closed', 'published', 'draft'));

-- 4. Just in case, update any existing weird data
UPDATE jobs SET status = 'draft' WHERE status ILIKE 'draft';
