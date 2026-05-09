-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id              uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email           text UNIQUE NOT NULL,
  role            text NOT NULL CHECK (role IN ('student', 'faculty', 'admin')),
  display_name    text NOT NULL,
  roll_number     text UNIQUE,
  employee_id     text UNIQUE,
  photo_url       text,
  fcm_token       text,
  face_status     text NOT NULL DEFAULT 'pending' CHECK (face_status IN ('pending', 'approved', 'rejected', 'flagged')),
  face_confidence float,
  tomato_credits  integer NOT NULL DEFAULT 50,
  streak_days     integer NOT NULL DEFAULT 0,
  reliability     float NOT NULL DEFAULT 1.0,
  is_runner       boolean NOT NULL DEFAULT false,
  runner_active   boolean NOT NULL DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- deliveries table
CREATE TABLE IF NOT EXISTS public.deliveries (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id     uuid NOT NULL REFERENCES public.profiles(id),
  runner_id        uuid REFERENCES public.profiles(id),
  pickup_location  text NOT NULL,
  dropoff_location text NOT NULL,
  item_size        text NOT NULL CHECK (item_size IN ('S', 'M', 'L')),
  urgency          float NOT NULL DEFAULT 1.0 CHECK (urgency >= 1.0 AND urgency <= 1.5),
  credit_cost      integer NOT NULL,
  status           text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'matching', 'accepted', 'picked_up', 'en_route', 'delivered', 'cancelled')),
  match_attempt    integer NOT NULL DEFAULT 0,
  notes            text,
  created_at       timestamptz NOT NULL DEFAULT now(),
  accepted_at      timestamptz,
  picked_up_at     timestamptz,
  delivered_at     timestamptz,
  confirmed_at     timestamptz
);

-- credit_transactions table
CREATE TABLE IF NOT EXISTS public.credit_transactions (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id uuid REFERENCES public.profiles(id),
  to_user_id   uuid NOT NULL REFERENCES public.profiles(id),
  amount       integer NOT NULL,
  type         text NOT NULL CHECK (type IN ('earn', 'spend', 'bonus', 'refund', 'admin_adjustment', 'signup')),
  reference_id uuid,
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- faculty_registry table (seeded by admin)
CREATE TABLE IF NOT EXISTS public.faculty_registry (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email        text UNIQUE NOT NULL,
  employee_id  text UNIQUE NOT NULL,
  display_name text,
  department   text
);

-- notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title      text NOT NULL,
  body       text NOT NULL,
  type       text,
  read_at    timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- runner_interests table
CREATE TABLE IF NOT EXISTS public.runner_interests (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id  uuid NOT NULL REFERENCES public.deliveries(id) ON DELETE CASCADE,
  runner_id    uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  expressed_at timestamptz NOT NULL DEFAULT now(),
  status       text NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting', 'selected', 'dismissed')),
  UNIQUE(delivery_id, runner_id)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_deliveries_requester ON public.deliveries(requester_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_runner ON public.deliveries(runner_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_status ON public.deliveries(status);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_to_user ON public.credit_transactions(to_user_id);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_from_user ON public.credit_transactions(from_user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_runner_interests_delivery ON public.runner_interests(delivery_id);

-- Enable Realtime for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.deliveries;
ALTER PUBLICATION supabase_realtime ADD TABLE public.runner_interests;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
