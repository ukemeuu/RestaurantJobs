
-- 1. Drop the existing check constraint
ALTER TABLE assessment_questions
DROP CONSTRAINT IF EXISTS assessment_questions_role_type_check;

-- 2. Add the new check constraint including 'top_roles'
ALTER TABLE assessment_questions
ADD CONSTRAINT assessment_questions_role_type_check 
CHECK (role_type IN ('foh', 'boh', 'top_roles'));

-- Optional: If you already inserted ''manager'' rows, you might want to update them:
-- UPDATE assessment_questions SET role_type = 'top_roles' WHERE role_type = 'manager';
