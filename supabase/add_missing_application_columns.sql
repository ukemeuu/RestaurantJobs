-- Add all missing columns to applications table
ALTER TABLE public.applications 
ADD COLUMN IF NOT EXISTS phone text,
ADD COLUMN IF NOT EXISTS location text,
ADD COLUMN IF NOT EXISTS desired_position text,
ADD COLUMN IF NOT EXISTS experience text,
ADD COLUMN IF NOT EXISTS cover_letter text;
