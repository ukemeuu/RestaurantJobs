-- Premium Candidate Subscription Schema
-- Add subscription tracking and premium features for job seekers

-- Create candidate_subscriptions table
CREATE TABLE IF NOT EXISTS candidate_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    plan_type TEXT NOT NULL CHECK (plan_type IN ('monthly', 'quarterly', 'yearly')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired')),
    amount INTEGER NOT NULL,
    payment_ref TEXT,
    start_date TIMESTAMPTZ DEFAULT NOW(),
    end_date TIMESTAMPTZ NOT NULL,
    auto_renew BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_candidate_subscriptions_user ON candidate_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_candidate_subscriptions_status ON candidate_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_candidate_subscriptions_end_date ON candidate_subscriptions(end_date);

-- Add premium columns to candidates table (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='candidates' AND column_name='is_premium') THEN
        ALTER TABLE candidates ADD COLUMN is_premium BOOLEAN DEFAULT false;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='candidates' AND column_name='premium_badge') THEN
        ALTER TABLE candidates ADD COLUMN premium_badge TEXT DEFAULT NULL;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='candidates' AND column_name='profile_views') THEN
        ALTER TABLE candidates ADD COLUMN profile_views INTEGER DEFAULT 0;
    END IF;
END $$;

-- Create job applications tracking table
CREATE TABLE IF NOT EXISTS job_applications_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
    viewed_at TIMESTAMPTZ DEFAULT NOW(),
    applied BOOLEAN DEFAULT false,
    notes TEXT,
    UNIQUE(user_id, job_id)
);

CREATE INDEX IF NOT EXISTS idx_job_tracking_user ON job_applications_tracking(user_id);
CREATE INDEX IF NOT EXISTS idx_job_tracking_job ON job_applications_tracking(job_id);

-- RLS Policies for candidate_subscriptions
ALTER TABLE candidate_subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can view their own subscriptions
CREATE POLICY "Users can view own subscriptions"
    ON candidate_subscriptions FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own subscriptions
CREATE POLICY "Users can insert own subscriptions"
    ON candidate_subscriptions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own subscriptions
CREATE POLICY "Users can update own subscriptions"
    ON candidate_subscriptions FOR UPDATE
    USING (auth.uid() = user_id);

-- RLS Policies for job_applications_tracking
ALTER TABLE job_applications_tracking ENABLE ROW LEVEL SECURITY;

-- Users can view their own tracking
CREATE POLICY "Users can view own job tracking"
    ON job_applications_tracking FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own tracking
CREATE POLICY "Users can insert own job tracking"
    ON job_applications_tracking FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own tracking
CREATE POLICY "Users can update own job tracking"
    ON job_applications_tracking FOR UPDATE
    USING (auth.uid() = user_id);

-- Function to check if user has active premium subscription
CREATE OR REPLACE FUNCTION is_premium_user(user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM candidate_subscriptions
        WHERE user_id = user_uuid
        AND status = 'active'
        AND end_date > NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update premium status on candidates table
CREATE OR REPLACE FUNCTION update_candidate_premium_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Update is_premium based on active subscription
    UPDATE candidates
    SET is_premium = is_premium_user(NEW.user_id),
        premium_badge = CASE 
            WHEN is_premium_user(NEW.user_id) THEN 'verified'
            ELSE NULL
        END
    WHERE id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update premium status
DROP TRIGGER IF EXISTS trigger_update_premium_status ON candidate_subscriptions;
CREATE TRIGGER trigger_update_premium_status
    AFTER INSERT OR UPDATE ON candidate_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_candidate_premium_status();

-- Function to expire old subscriptions (run via cron)
CREATE OR REPLACE FUNCTION expire_old_subscriptions()
RETURNS void AS $$
BEGIN
    UPDATE candidate_subscriptions
    SET status = 'expired'
    WHERE status = 'active'
    AND end_date < NOW();
    
    -- Update candidates table
    UPDATE candidates c
    SET is_premium = false,
        premium_badge = NULL
    WHERE NOT EXISTS (
        SELECT 1 FROM candidate_subscriptions cs
        WHERE cs.user_id = c.id
        AND cs.status = 'active'
        AND cs.end_date > NOW()
    );
END;
$$ LANGUAGE plpgsql;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON candidate_subscriptions TO authenticated;
GRANT ALL ON job_applications_tracking TO authenticated;
GRANT EXECUTE ON FUNCTION is_premium_user TO authenticated;
