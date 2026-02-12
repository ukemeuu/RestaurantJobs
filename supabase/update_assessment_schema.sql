
-- Add status column to candidate_assessments if it doesn't exist
ALTER TABLE candidate_assessments 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'completed'; -- Default to completed for existing records

-- Make role_selected nullable or ensure it's handled (it should be fine)
-- Add constraint validation for status
ALTER TABLE candidate_assessments 
ADD CONSTRAINT check_status CHECK (status IN ('in_progress', 'completed', 'abandoned'));
