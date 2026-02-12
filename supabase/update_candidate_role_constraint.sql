
-- 1. Drop existing check constraint on role_selected if it exists
-- Note: The constraint name might vary. We'll try to drop common names or just add the new one if we can replacing.
-- It's safer to just ADD the new value to the check or drop/recreate.

-- Assuming the constraint is named checking role_selected values.
-- If you created the table with a specific check, we need to know its name. 
-- However, often it's easiest to just drop the constraint by name if known, or ALTER COLUMN.

-- Let's try to drop the constraint 'candidate_assessments_role_selected_check' which is standard naming.
ALTER TABLE candidate_assessments
DROP CONSTRAINT IF EXISTS candidate_assessments_role_selected_check;

-- 2. Add the constraint back with 'top_roles' included
ALTER TABLE candidate_assessments
ADD CONSTRAINT candidate_assessments_role_selected_check
CHECK (role_selected IN ('foh', 'boh', 'manager', 'top_roles'));

-- Note: We include 'manager' for legacy records, and 'top_roles' for new ones.
