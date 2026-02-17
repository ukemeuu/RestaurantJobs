-- FIX RECOMMENDATION CONSTRAINT
-- The frontend uses 'Strong Hire', 'Hire', 'No Hire', and 'Flagged (Validity)'.
-- The previous schema restriction was too tight ('Highly Recommend' etc).

ALTER TABLE candidate_assessments
DROP CONSTRAINT IF EXISTS candidate_assessments_recommendation_check;

ALTER TABLE candidate_assessments
ADD CONSTRAINT candidate_assessments_recommendation_check
CHECK (recommendation IN ('Strong Hire', 'Hire', 'No Hire', 'Flagged (Validity)', 'Review', 'Highly Recommend', 'Consider'));
