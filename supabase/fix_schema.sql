-- 1. Fix Jobs Table (Missing Columns)
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS salary_min integer;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS salary_max integer;
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS experience_level text;

-- 2. Fix Relationships (Applications -> Candidate Profiles)
-- This allows: .select('*, candidate_profiles(*)')
ALTER TABLE applications 
ADD CONSTRAINT fk_applications_candidate_profile 
FOREIGN KEY (candidate_id) 
REFERENCES candidate_profiles(id);

-- If the above fails because of existing data violating the constraint, 
-- you might need to ensure all candidate_ids in applications exist in candidate_profiles first.
-- But for now, try running this.
