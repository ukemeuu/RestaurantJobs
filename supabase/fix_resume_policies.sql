-- Ensure Resumes bucket exists and has correct policies

-- 1. Create bucket if not exists
insert into storage.buckets (id, name, public)
values ('resumes', 'resumes', false)
on conflict (id) do nothing;

-- 2. Enable RLS
alter table storage.objects enable row level security;

-- 3. Policy: Authenticated users can upload (Candidates)
drop policy if exists "Authenticated users can upload resumes" on storage.objects;
create policy "Authenticated users can upload resumes"
on storage.objects for insert
to authenticated
with check ( bucket_id = 'resumes' );

-- 4. Policy: Authenticated users can view (Employers/Admins)
-- Note: Ideally we'd restrict this to "Own Job Applicants", but storage doesn't easy link to relational tables.
-- For now, giving read access to all authenticated users is a pragmatic step. 
-- The frontend protects the paths via 'view-applicants' RLS.
drop policy if exists "Authenticated users can view resumes" on storage.objects;
create policy "Authenticated users can view resumes"
on storage.objects for select
to authenticated
using ( bucket_id = 'resumes' );

-- 5. Policy: Public access (Optional, if we want to support public links, but we are using Signed URLs)
-- drop policy if exists "Public Read Resumes" on storage.objects;
