
-- COMPREHENSIVE FIX SCRIPT FOR ASSESSMENT SCHEMA
-- Run this entire script in the Supabase SQL Editor

-- 1. Ensure 'status' column exists in candidate_assessments
ALTER TABLE candidate_assessments 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'completed';

-- 2. Update Status Constraint
ALTER TABLE candidate_assessments 
DROP CONSTRAINT IF EXISTS check_status;

ALTER TABLE candidate_assessments 
ADD CONSTRAINT check_status 
CHECK (status IN ('in_progress', 'completed', 'abandoned'));

-- 3. Update Role Constraint on CANDIDATE_ASSESSMENTS table
-- (This is likely why "Start Assessment" is failing)
ALTER TABLE candidate_assessments
DROP CONSTRAINT IF EXISTS candidate_assessments_role_selected_check;

ALTER TABLE candidate_assessments
ADD CONSTRAINT candidate_assessments_role_selected_check
CHECK (role_selected IN ('foh', 'boh', 'manager', 'top_roles', 'smm'));

-- 4. Update Role Constraint on ASSESSMENT_QUESTIONS table
-- (This is needed for the questions seed to work)
ALTER TABLE assessment_questions
DROP CONSTRAINT IF EXISTS assessment_questions_role_type_check;

ALTER TABLE assessment_questions
ADD CONSTRAINT assessment_questions_role_type_check 
CHECK (role_type IN ('foh', 'boh', 'manager', 'top_roles', 'smm'));

-- 5. (Optional) RLS Policies - Ensure public/anon can insert
-- Adjust this if you use authenticated users only, but for candidates it's usually public
-- ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Allow public insert" ON candidate_assessments FOR INSERT WITH CHECK (true);
-- CREATE POLICY "Allow public update own" ... (This is harder without auth, usually relies on returning ID)
