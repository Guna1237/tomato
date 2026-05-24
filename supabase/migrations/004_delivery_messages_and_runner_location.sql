-- delivery_messages: real-time chat between requester and runner
CREATE TABLE IF NOT EXISTS public.delivery_messages (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id   uuid NOT NULL REFERENCES public.deliveries(id) ON DELETE CASCADE,
  sender_id     uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body          text NOT NULL CHECK (char_length(body) > 0),
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS delivery_messages_delivery_id_idx ON public.delivery_messages(delivery_id);
CREATE INDEX IF NOT EXISTS delivery_messages_created_at_idx ON public.delivery_messages(created_at);

-- RLS: only the requester and runner of the delivery can read/write messages
ALTER TABLE public.delivery_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "participants can view messages"
  ON public.delivery_messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.deliveries d
      WHERE d.id = delivery_id
        AND (d.requester_id = auth.uid() OR d.runner_id = auth.uid())
    )
  );

CREATE POLICY "participants can send messages"
  ON public.delivery_messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.deliveries d
      WHERE d.id = delivery_id
        AND (d.requester_id = auth.uid() OR d.runner_id = auth.uid())
    )
  );

-- runner real-time GPS columns on deliveries
ALTER TABLE public.deliveries
  ADD COLUMN IF NOT EXISTS runner_lat  double precision,
  ADD COLUMN IF NOT EXISTS runner_lng  double precision,
  ADD COLUMN IF NOT EXISTS runner_updated_at timestamptz;
