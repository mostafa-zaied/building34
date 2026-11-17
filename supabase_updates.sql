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

-- 5. Apartment Extra Charges (per-apartment repairs/dues within a month)
CREATE TABLE IF NOT EXISTS public.apartment_extra_charges (
  id BIGSERIAL PRIMARY KEY,
  month_id BIGINT NOT NULL REFERENCES public.months(id) ON DELETE CASCADE,
  apt_num INT NOT NULL,
  amount NUMERIC NOT NULL,
  reason TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.apartment_extra_charges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read apartment_extra_charges" ON public.apartment_extra_charges;
CREATE POLICY "Public read apartment_extra_charges"
  ON public.apartment_extra_charges FOR SELECT USING (true);

CREATE OR REPLACE FUNCTION public.admin_add_extra_charge(
  p_admin_pass TEXT,
  p_month_id BIGINT,
  p_apt_nums INT[],
  p_amount NUMERIC,
  p_reason TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pass TEXT;
  v_apt INT;
BEGIN
  SELECT admin_password INTO v_pass FROM public.building_settings WHERE id = 1;
  IF v_pass IS NULL OR p_admin_pass <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  FOREACH v_apt IN ARRAY p_apt_nums LOOP
    INSERT INTO public.apartment_extra_charges (month_id, apt_num, amount, reason)
    VALUES (p_month_id, v_apt, p_amount, p_reason);
  END LOOP;

  RETURN jsonb_build_object('ok', true);
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_delete_extra_charge(
  p_admin_pass TEXT,
  p_id BIGINT
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

  DELETE FROM public.apartment_extra_charges WHERE id = p_id;
  RETURN jsonb_build_object('ok', true);
END;
$$;

-- 5. Page Views / Visit Analytics (Admin-only visibility)
CREATE TABLE IF NOT EXISTS public.page_views (
  id BIGSERIAL PRIMARY KEY,
  visitor_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_page_views_created_at
  ON public.page_views (created_at DESC);

ALTER TABLE public.page_views ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.record_page_view(
  p_visitor_id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF p_visitor_id IS NULL OR length(trim(p_visitor_id)) = 0 THEN
    RETURN;
  END IF;
  INSERT INTO public.page_views (visitor_id)
  VALUES (left(trim(p_visitor_id), 120));
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_get_page_view_stats(
  p_admin_pass TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pass TEXT;
  v_total BIGINT;
  v_unique BIGINT;
  v_today BIGINT;
  v_week BIGINT;
  v_up_opens BIGINT;
  v_up_votes BIGINT;
BEGIN
  SELECT admin_password INTO v_pass FROM public.building_settings WHERE id = 1;
  IF v_pass IS NULL OR p_admin_pass <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  SELECT
    COUNT(*),
    COUNT(DISTINCT visitor_id),
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', NOW())),
    COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '7 days')
  INTO v_total, v_unique, v_today, v_week
  FROM public.page_views;

  SELECT
    COUNT(*) FILTER (WHERE event_type = 'open'),
    COUNT(*) FILTER (WHERE event_type = 'vote')
  INTO v_up_opens, v_up_votes
  FROM public.upcoming_directory_events;

  RETURN jsonb_build_object(
    'ok', true,
    'total_views', COALESCE(v_total, 0),
    'unique_visitors', COALESCE(v_unique, 0),
    'today_views', COALESCE(v_today, 0),
    'week_views', COALESCE(v_week, 0),
    'upcoming_opens', COALESCE(v_up_opens, 0),
    'upcoming_votes', COALESCE(v_up_votes, 0)
  );
END;
$$;

-- 6. Upcoming Services Directory Interest Tracking (Admin-only stats)
CREATE TABLE IF NOT EXISTS public.upcoming_directory_events (
  id BIGSERIAL PRIMARY KEY,
  visitor_id TEXT NOT NULL,
  event_type TEXT NOT NULL CHECK (event_type IN ('open', 'vote')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_upcoming_dir_events_type
  ON public.upcoming_directory_events (event_type, visitor_id);

ALTER TABLE public.upcoming_directory_events ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.record_upcoming_directory_event(
  p_visitor_id TEXT,
  p_event_type TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_vid TEXT;
BEGIN
  IF p_visitor_id IS NULL OR length(trim(p_visitor_id)) = 0 THEN
    RETURN;
  END IF;
  IF p_event_type NOT IN ('open', 'vote') THEN
    RETURN;
  END IF;
  v_vid := left(trim(p_visitor_id), 120);

  IF p_event_type = 'vote' THEN
    IF EXISTS (
      SELECT 1 FROM public.upcoming_directory_events
      WHERE visitor_id = v_vid AND event_type = 'vote'
    ) THEN
      RETURN;
    END IF;
  END IF;

  INSERT INTO public.upcoming_directory_events (visitor_id, event_type)
  VALUES (v_vid, p_event_type);
END;
$$;

-- 7. Verify Apartment Passcode before opening apartment details
CREATE OR REPLACE FUNCTION public.verify_apartment_passcode(
  p_apt_num INT,
  p_passcode TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_expected TEXT;
BEGIN
  SELECT passcode INTO v_expected
  FROM public.apartments
  WHERE apt_num = p_apt_num;

  IF v_expected IS NULL OR trim(COALESCE(p_passcode, '')) <> v_expected THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_apt_pass');
  END IF;

  RETURN jsonb_build_object('ok', true);
END;
$$;
