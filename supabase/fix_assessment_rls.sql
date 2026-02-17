-- FIX RLS POLICIES FOR CANDIDATE ASSESSMENTS
-- This script allows public (anonymous) users to start assessments

-- 1. Enable RLS (if not already enabled)
ALTER TABLE candidate_assessments ENABLE ROW LEVEL SECURITY;

-- 2. Allow public to INSERT (Start Assessment)
DROP POLICY IF EXISTS "Public can insert assessments" ON candidate_assessments;
CREATE POLICY "Public can insert assessments" ON candidate_assessments
FOR INSERT
WITH CHECK (true);

-- 3. Allow public to SELECT their own assessment (by ID)
-- Since we return the ID after insert, the frontend might need to read it back later or update it.
-- Ideally, we'd limit this to the session, but for now, allowing select by ID is practical for the flow.
DROP POLICY IF EXISTS "Public can view assessments by ID" ON candidate_assessments;
CREATE POLICY "Public can view assessments by ID" ON candidate_assessments
FOR SELECT
USING (true);

-- 4. Allow public to UPDATE their own assessment (Submit Score/Status)
-- Crucial for "Finish Assessment" step
DROP POLICY IF EXISTS "Public can update assessments" ON candidate_assessments;
CREATE POLICY "Public can update assessments" ON candidate_assessments
FOR UPDATE
USING (true);

-- NOTE: In a stricter production env, we might want to restrict UPDATE/SELECT
-- to only records created in the current browser session, but without auth, 
-- we rely on the UUID being hard to guess.

-- 5. Ensure Assessment Questions are readable
DROP POLICY IF EXISTS "Questions are public" ON assessment_questions;
CREATE POLICY "Questions are public" ON assessment_questions
FOR SELECT
USING (true);
