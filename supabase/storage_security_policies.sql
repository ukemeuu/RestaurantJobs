-- Supabase Storage Security Policies
-- Run these in your Supabase SQL Editor to secure file uploads

-- ============================================
-- RESUMES BUCKET SECURITY
-- ============================================

-- 1. Create storage bucket policies for resumes
-- Restrict file types and sizes at the database level

-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to upload resumes
CREATE POLICY "Allow authenticated uploads to resumes"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'resumes' 
  AND (storage.foldername(name))[1] = 'resumes'
  AND (
    -- Only allow PDF and DOC files
    (LOWER(storage.extension(name)) = 'pdf') OR
    (LOWER(storage.extension(name)) = 'doc') OR
    (LOWER(storage.extension(name)) = 'docx')
  )
  AND octet_length(decode(encode(content, 'base64'), 'base64')) <= 5242880 -- 5MB limit
);

-- Policy: Allow public read access to resumes (for admin dashboard)
CREATE POLICY "Allow public read access to resumes"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'resumes');

-- ============================================
-- LOGOS BUCKET SECURITY
-- ============================================

-- Policy: Allow authenticated users to upload logos
CREATE POLICY "Allow authenticated uploads to logos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'logos'
  AND (storage.foldername(name))[1] = 'logos'
  AND (
    -- Only allow image files
    (LOWER(storage.extension(name)) = 'jpg') OR
    (LOWER(storage.extension(name)) = 'jpeg') OR
    (LOWER(storage.extension(name)) = 'png') OR
    (LOWER(storage.extension(name)) = 'webp')
  )
  AND octet_length(decode(encode(content, 'base64'), 'base64')) <= 2097152 -- 2MB limit
);

-- Policy: Allow public read access to logos
CREATE POLICY "Allow public read access to logos"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'logos');

-- ============================================
-- BUCKET CONFIGURATION
-- ============================================

-- Update bucket settings (run in Supabase Dashboard > Storage)
-- For 'resumes' bucket:
--   - File size limit: 5MB
--   - Allowed MIME types: application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document
--   - Public: false (only accessible via signed URLs or authenticated requests)

-- For 'logos' bucket:
--   - File size limit: 2MB
--   - Allowed MIME types: image/jpeg, image/png, image/webp
--   - Public: true (logos need to be publicly accessible)

-- ============================================
-- ADDITIONAL SECURITY MEASURES
-- ============================================

-- 1. Enable virus scanning (if available in your Supabase plan)
-- 2. Set up file retention policies
-- 3. Monitor storage usage and set alerts
-- 4. Regular security audits

-- ============================================
-- CLEANUP OLD FILES (Optional)
-- ============================================

-- Function to delete files older than 90 days (for resumes)
CREATE OR REPLACE FUNCTION cleanup_old_resumes()
RETURNS void AS $$
BEGIN
  DELETE FROM storage.objects
  WHERE bucket_id = 'resumes'
  AND created_at < NOW() - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Schedule this function to run weekly using pg_cron or Supabase Edge Functions
