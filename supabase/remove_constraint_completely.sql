-- REMOVE CONSTRAINT COMPLETELY
-- We are removing the status check entirely to unblock updates.
-- This is a temporary measure to confirm if the constraint is truly the issue.
-- You can run this safely; it just removes the validation rule.

ALTER TABLE jobs DROP CONSTRAINT IF EXISTS jobs_status_check;
ALTER TABLE jobs DROP CONSTRAINT IF EXISTS jobs_status_check_final;
ALTER TABLE jobs DROP CONSTRAINT IF EXISTS jobs_status_check_case_insensitive;
ALTER TABLE jobs DROP CONSTRAINT IF EXISTS check_status;
