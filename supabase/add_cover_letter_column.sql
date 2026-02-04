-- Add cover_letter column to applications table
ALTER TABLE public.applications 
ADD COLUMN IF NOT EXISTS cover_letter text;

-- Ensure RLS allows inserting/viewing it (existing policies typically use 'true' for insert, so should be fine)
-- But explicit granting is good practice if column security was granular (it's not here usually).
