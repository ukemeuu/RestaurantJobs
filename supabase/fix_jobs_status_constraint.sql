-- FIX JOBS STATUS CONSTRAINT
-- The frontend allows 'draft', but the database constraint was missing it.
-- Also checking for other potential statuses.

ALTER TABLE jobs
DROP CONSTRAINT IF EXISTS jobs_status_check;

ALTER TABLE jobs
ADD CONSTRAINT jobs_status_check
CHECK (status IN ('pending', 'approved', 'rejected', 'closed', 'published', 'draft'));
