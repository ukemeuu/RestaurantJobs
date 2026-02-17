-- WIDEN JOBS STATUS CONSTRAINT (CASE INSENSITIVE)
-- The error persists even though 'draft' is seemingly in the list.
-- This usually means the input is "Draft" (Title Case) or "DRAFT" (Upper Case),
-- while the database expects exactly "draft".

-- 1. Drop existing constraints
ALTER TABLE jobs DROP CONSTRAINT IF EXISTS jobs_status_check;
ALTER TABLE jobs DROP CONSTRAINT IF EXISTS jobs_status_check_final;

-- 2. Add a CASE-INSENSITIVE constraint
-- We use lower(status) to ensure "Draft", "draft", "DRAFT" are all accepted.
ALTER TABLE jobs
ADD CONSTRAINT jobs_status_check_case_insensitive
CHECK (lower(status) IN ('pending', 'approved', 'rejected', 'closed', 'published', 'draft'));
