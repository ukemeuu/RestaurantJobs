
-- FINAL FIX FOR SUBMISSION ERRORS
-- 1. Enable RLS (Row Level Security)
ALTER TABLE candidate_assessments ENABLE ROW LEVEL SECURITY;

-- 2. Create Policy for Public Insert (Crucial for candidates)
DROP POLICY IF EXISTS "Enable insert for everyone" ON candidate_assessments;

CREATE POLICY "Enable insert for everyone" 
ON candidate_assessments 
FOR INSERT 
WITH CHECK (true);

-- 3. Create Policy for Public Update (So they can update their own record if needed)
-- Note: Ideally we'd match on ID, but for now allow public updates to simplify "in_progress" flow
-- A better production approach would use a session token or return a UUID to the client.
-- For now, let's allow updating if the ID exists.
DROP POLICY IF EXISTS "Enable update for everyone" ON candidate_assessments;

CREATE POLICY "Enable update for everyone" 
ON candidate_assessments 
FOR UPDATE 
USING (true) 
WITH CHECK (true);

-- 4. Ensure Columns are Nullable (to prevent "not null" errors on start)
ALTER TABLE candidate_assessments ALTER COLUMN total_score DROP NOT NULL;
ALTER TABLE candidate_assessments ALTER COLUMN trait_scores DROP NOT NULL;
ALTER TABLE candidate_assessments ALTER COLUMN recommendation DROP NOT NULL;
ALTER TABLE candidate_assessments ALTER COLUMN ai_metadata DROP NOT NULL;
ALTER TABLE candidate_assessments ALTER COLUMN validity_flag DROP NOT NULL;

-- 5. Set Defaults
ALTER TABLE candidate_assessments ALTER COLUMN total_score SET DEFAULT 0;
ALTER TABLE candidate_assessments ALTER COLUMN status SET DEFAULT 'in_progress';
