-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faculty_registry ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.runner_interests ENABLE ROW LEVEL SECURITY;

-- Helper function to check if current user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- PROFILES policies
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "Runners can view other profiles for matching" ON public.profiles
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.is_runner = true)
  );

CREATE POLICY "Requesters can view runner profiles" ON public.profiles
  FOR SELECT USING (true);  -- All logged-in users can view profiles (needed for matching cards)

CREATE POLICY "Admin can view all profiles" ON public.profiles
  FOR ALL USING (public.is_admin());

CREATE POLICY "Edge functions can insert profiles" ON public.profiles
  FOR INSERT WITH CHECK (true);  -- Edge Functions use service role, bypasses RLS

-- DELIVERIES policies
CREATE POLICY "Users can view own deliveries" ON public.deliveries
  FOR SELECT USING (requester_id = auth.uid() OR runner_id = auth.uid());

CREATE POLICY "Runners can view open deliveries" ON public.deliveries
  FOR SELECT USING (status = 'matching');

CREATE POLICY "Users can insert own deliveries" ON public.deliveries
  FOR INSERT WITH CHECK (requester_id = auth.uid());

CREATE POLICY "Users can update own deliveries" ON public.deliveries
  FOR UPDATE USING (requester_id = auth.uid() OR runner_id = auth.uid());

CREATE POLICY "Admin can view all deliveries" ON public.deliveries
  FOR ALL USING (public.is_admin());

-- CREDIT_TRANSACTIONS policies
CREATE POLICY "Users can view own transactions" ON public.credit_transactions
  FOR SELECT USING (to_user_id = auth.uid() OR from_user_id = auth.uid());

CREATE POLICY "Admin can insert admin adjustments" ON public.credit_transactions
  FOR INSERT WITH CHECK (public.is_admin() AND type = 'admin_adjustment');

-- FACULTY_REGISTRY policies
CREATE POLICY "Only admin can view faculty registry" ON public.faculty_registry
  FOR ALL USING (public.is_admin());

-- NOTIFICATIONS policies
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- RUNNER_INTERESTS policies
CREATE POLICY "Runners can insert own interests" ON public.runner_interests
  FOR INSERT WITH CHECK (runner_id = auth.uid());

CREATE POLICY "Runners can view own interests" ON public.runner_interests
  FOR SELECT USING (runner_id = auth.uid());

CREATE POLICY "Requesters can view interests on own delivery" ON public.runner_interests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.deliveries d
      WHERE d.id = delivery_id AND d.requester_id = auth.uid()
    )
  );

CREATE POLICY "Admin can view all interests" ON public.runner_interests
  FOR ALL USING (public.is_admin());
