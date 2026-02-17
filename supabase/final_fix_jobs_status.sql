-- FINAL FIX FOR JOBS STATUS
-- The error "violates check constraint 'jobs_status_check'" persists.
-- This script REMOVES the old constraint completely and adds a NEW one with a different name.

-- 1. Drop the old constraint (and any variations)
ALTER TABLE jobs DROP CONSTRAINT IF EXISTS jobs_status_check;
ALTER TABLE jobs DROP CONSTRAINT IF EXISTS jobs_status_check_final;

-- 2. Add the new constraint with a unique name
-- This ensures 'draft' (and others) are definitely allowed.
ALTER TABLE jobs
ADD CONSTRAINT jobs_status_check_final
CHECK (status IN ('pending', 'approved', 'rejected', 'closed', 'published', 'draft'));

-- 3. Verify (Optional)
-- This query will do nothing if the constraint is valid.
-- SELECT count(*) FROM jobs;
