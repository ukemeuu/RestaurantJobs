
-- ADD SMM ROLE & QUESTIONS
-- Run this script to fully enable the Social Media Manager role.

-- 1. Update Constraint on QUESTIONS table
ALTER TABLE assessment_questions
DROP CONSTRAINT IF EXISTS assessment_questions_role_type_check;

ALTER TABLE assessment_questions
ADD CONSTRAINT assessment_questions_role_type_check 
CHECK (role_type IN ('foh', 'boh', 'manager', 'top_roles', 'smm'));

-- 2. Update Constraint on CANDIDATE ASSESSMENTS table
ALTER TABLE candidate_assessments
DROP CONSTRAINT IF EXISTS candidate_assessments_role_selected_check;

ALTER TABLE candidate_assessments
ADD CONSTRAINT candidate_assessments_role_selected_check
CHECK (role_selected IN ('foh', 'boh', 'manager', 'top_roles', 'smm'));

-- 3. Insert SMM Questions
-- Please check supabase/seed_questions_smm.sql
