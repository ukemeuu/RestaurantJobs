-- Create candidate_subscriptions table
CREATE TABLE IF NOT EXISTS public.candidate_subscriptions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) NOT NULL,
    plan_type text NOT NULL, -- 'monthly', 'quarterly', 'yearly'
    amount numeric NOT NULL,
    payment_ref text,
    status text DEFAULT 'active', -- 'active', 'expired', 'pending'
    start_date timestamp with time zone DEFAULT now(),
    end_date timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.candidate_subscriptions ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own subscriptions" 
ON public.candidate_subscriptions FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own subscriptions" 
ON public.candidate_subscriptions FOR INSERT 
WITH CHECK (auth.uid() = user_id);
