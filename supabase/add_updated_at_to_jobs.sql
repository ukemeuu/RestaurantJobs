-- Add updated_at column to jobs table
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL;
