-- Fix Foreign Key Relationship for Jobs and Employers
-- The previous schema referenced auth.users, which prevents PostgREST from joining 'jobs' and 'employers' directly.
-- We need a foreign key from jobs.employer_id -> employers.id

-- 1. Drop existing FK if it exists (referencing auth.users)
-- Note: Constraint names usually follow strict patterns, but if it was created inline it might be auto-generated.
-- We will attempt to drop the likely name or just add a new one that PostgREST can find.

DO $$
BEGIN
    -- Try to drop generic constraint if known, otherwise we might rely on the new one being picked up.
    -- Ideally we inspect information_schema but explicit naming is better.
    -- For now, let's just ADD the correct relationship. PostgREST will use it.
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'jobs_employer_id_fkey_employers'
    ) THEN
        ALTER TABLE public.jobs
        ADD CONSTRAINT jobs_employer_id_fkey_employers
        FOREIGN KEY (employer_id)
        REFERENCES public.employers(id);
    END IF;
END $$;

-- 2. Explicitly notify PostgREST (usually auto-detected after schema cache reload)
-- You might need to reload the schema cache in Supabase dashboard API settings.
