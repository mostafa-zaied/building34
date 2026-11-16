-- Run this SQL in Supabase SQL Editor to enable:
-- 1) Announcement Banner (building_settings.announcement + get_announcement)
-- 2) Emergency Fund Transactions Log (emergency_transactions)
-- 3) Feedback Status & Admin Reply (feedback_posts.status, feedback_posts.admin_reply)

-- 1. Announcement column on building_settings + RPCs
ALTER TABLE public.building_settings
  ADD COLUMN IF NOT EXISTS announcement TEXT DEFAULT '';

CREATE OR REPLACE FUNCTION public.get_announcement()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_ann TEXT;
BEGIN
  SELECT COALESCE(announcement, '') INTO v_ann FROM public.building_settings WHERE id = 1;
  RETURN COALESCE(v_ann, '');
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_set_announcement(
  p_admin_pass TEXT,
  p_announcement TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pass TEXT;
BEGIN
  SELECT admin_password INTO v_pass FROM public.building_settings WHERE id = 1;
  IF v_pass IS NULL OR p_admin_pass <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.building_settings
  SET announcement = COALESCE(p_announcement, '')
  WHERE id = 1;

  RETURN jsonb_build_object('ok', true);
END;
$$;

-- 2. Emergency Transactions table & RPCs
CREATE TABLE IF NOT EXISTS public.emergency_transactions (
  id BIGSERIAL PRIMARY KEY,
  amount NUMERIC NOT NULL,
  reason TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.emergency_transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read emergency_transactions" ON public.emergency_transactions;
CREATE POLICY "Public read emergency_transactions"
  ON public.emergency_transactions FOR SELECT USING (true);

CREATE OR REPLACE FUNCTION public.admin_add_emergency_tx(
  p_admin_pass TEXT,
  p_amount NUMERIC,
  p_reason TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pass TEXT;
BEGIN
  SELECT admin_password INTO v_pass FROM public.building_settings WHERE id = 1;
  IF v_pass IS NULL OR p_admin_pass <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  INSERT INTO public.emergency_transactions (amount, reason)
  VALUES (p_amount, p_reason);

  UPDATE public.building_settings
  SET base_emergency_fund = GREATEST(0, COALESCE(base_emergency_fund, 0) - p_amount)
  WHERE id = 1;

  RETURN jsonb_build_object('ok', true);
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_delete_emergency_tx(
  p_admin_pass TEXT,
  p_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pass TEXT;
  v_amount NUMERIC;
BEGIN
  SELECT admin_password INTO v_pass FROM public.building_settings WHERE id = 1;
  IF v_pass IS NULL OR p_admin_pass <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  SELECT amount INTO v_amount FROM public.emergency_transactions WHERE id = p_id;
  IF v_amount IS NOT NULL THEN
    DELETE FROM public.emergency_transactions WHERE id = p_id;
    UPDATE public.building_settings
    SET base_emergency_fund = COALESCE(base_emergency_fund, 0) + v_amount
    WHERE id = 1;
  END IF;

  RETURN jsonb_build_object('ok', true);
END;
$$;

-- 3. Feedback Status & Admin Reply
ALTER TABLE public.feedback_posts
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS admin_reply TEXT;

CREATE OR REPLACE FUNCTION public.admin_update_feedback_status(
  p_admin_pass TEXT,
  p_id BIGINT,
  p_status TEXT,
  p_admin_reply TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pass TEXT;
BEGIN
  SELECT admin_password INTO v_pass FROM public.building_settings WHERE id = 1;
  IF v_pass IS NULL OR p_admin_pass <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.feedback_posts
  SET status = COALESCE(p_status, 'pending'),
      admin_reply = p_admin_reply
  WHERE id = p_id;

  RETURN jsonb_build_object('ok', true);
END;
$$;

-- 4. Remove Month RPC (admin only, prevents deleting the last remaining month)
CREATE OR REPLACE FUNCTION public.admin_delete_month(
  p_admin_pass TEXT,
  p_month_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pass TEXT;
  v_count INT;
BEGIN
  SELECT admin_password INTO v_pass FROM public.building_settings WHERE id = 1;
  IF v_pass IS NULL OR p_admin_pass <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  SELECT COUNT(*) INTO v_count FROM public.months;
  IF v_count <= 1 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_cannot_delete_last_month');
  END IF;

  DELETE FROM public.payments WHERE month_id = p_month_id;
  DELETE FROM public.months WHERE id = p_month_id;

  RETURN jsonb_build_object('ok', true);
END;
$$;
