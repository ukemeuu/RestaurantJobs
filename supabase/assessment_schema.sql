-- Assessment Schema

-- 1. Assessment Questions
CREATE TABLE IF NOT EXISTS assessment_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_type TEXT NOT NULL CHECK (role_type IN ('foh', 'boh')),
    question_text TEXT NOT NULL,
    category TEXT NOT NULL,
    is_validity BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Candidate Assessments
CREATE TABLE IF NOT EXISTS candidate_assessments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_name TEXT NOT NULL,
    candidate_email TEXT NOT NULL,
    role_selected TEXT NOT NULL CHECK (role_selected IN ('foh', 'boh')),
    total_score INTEGER NOT NULL,
    trait_scores JSONB DEFAULT '{}'::jsonb,
    
    -- New Analytical Columns
    recommendation TEXT CHECK (recommendation IN ('Highly Recommend', 'Consider', 'Do Not Hire')),
    ai_metadata JSONB DEFAULT '{}'::jsonb, -- Store { "time_taken_seconds": 120, "variance": 0.2, "flagged": true }
    validity_flag BOOLEAN DEFAULT false, -- True if they failed the validity check
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE assessment_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidate_assessments ENABLE ROW LEVEL SECURITY;

-- 3. Policies
-- Everyone can read questions (publicly accessible for the test)
create policy "Public can view questions" on assessment_questions
  for select using (true);

-- Anyone can insert assessments (public submission)
create policy "Public can submit assessments" on candidate_assessments
  for insert with check (true);

-- Only Admin can view assessments
create policy "Admins can view assessments" on candidate_assessments
  for select using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );

-- Only Admin can manage questions
create policy "Admins can manage questions" on assessment_questions
  for all using (
    exists (select 1 from user_roles where id = auth.uid() and role = 'admin')
  );
