-- Add phone_number to profiles for runner/requester contact during delivery
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS phone_number text;
