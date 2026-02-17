-- FORCE FIX JOBS STATUS CONSTRAINT
-- Use this if the previous script didn't resolve the "jobs_status_check" error.

-- 1. Explicitly drop the constraint (if it exists)
ALTER TABLE jobs
DROP CONSTRAINT IF EXISTS jobs_status_check;

-- 2. Re-create the constraint with ALL valid statuses
-- pending: Default for new jobs
-- approved: Live on site (legacy/standard)
-- published: Live on site (legacy)
-- rejected: Admin rejected
-- closed: Employer closed
-- draft: Employer draft (The one causing errors)

ALTER TABLE jobs
ADD CONSTRAINT jobs_status_check
CHECK (status IN ('pending', 'approved', 'rejected', 'closed', 'published', 'draft'));

-- 3. Verify it works (Optional query to run after)
-- SELECT * FROM jobs LIMIT 1;
