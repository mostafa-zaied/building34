-- =============================================================================
-- MABNA CARE SaaS — Multi-Building & Super Admin RPCs
-- Saved for branch `mabna2`
-- =============================================================================

CREATE OR REPLACE FUNCTION public.saas_building_to_json(p_row public.buildings)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  SELECT jsonb_build_object(
    'id', p_row.id,
    'code', p_row.code,
    'name', p_row.name,
    'city', p_row.city,
    'apts_count', p_row.apts_count,
    'instapay_phone', p_row.instapay_phone,
    'instapay_url', p_row.instapay_url,
    'manager_whatsapp', p_row.manager_whatsapp,
    'base_emergency_fund', p_row.base_emergency_fund,
    'announcement', COALESCE(p_row.announcement, ''),
    'require_apt_pass_on_open', COALESCE(p_row.require_apt_pass_on_open, true),
    'subscription_status', p_row.subscription_status,
    'trial_ends_at', p_row.trial_ends_at,
    'subscription_ends_at', p_row.subscription_ends_at,
    'created_at', p_row.created_at
  );
$function$;

CREATE OR REPLACE FUNCTION public.saas_get_building_by_code(p_code text DEFAULT NULL::text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_clean text := trim(COALESCE(p_code, ''));
  v_row public.buildings;
  v_support text;
BEGIN
  SELECT COALESCE(support_whatsapp, '201021950445') INTO v_support
  FROM public.platform_settings
  WHERE id = 1;

  IF v_clean = '' THEN
    SELECT * INTO v_row FROM public.buildings WHERE id = 1;
  ELSE
    SELECT * INTO v_row FROM public.buildings WHERE upper(code) = upper(v_clean);
  END IF;

  IF v_row.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_building_not_found');
  END IF;

  RETURN jsonb_build_object(
    'ok', true,
    'support_whatsapp', COALESCE(v_support, '201021950445'),
    'building', public.saas_building_to_json(v_row)
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_get_building_by_id(p_building_id integer DEFAULT 1)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_row public.buildings;
  v_support text;
BEGIN
  SELECT COALESCE(support_whatsapp, '201021950445') INTO v_support
  FROM public.platform_settings
  WHERE id = 1;

  SELECT * INTO v_row FROM public.buildings WHERE id = COALESCE(p_building_id, 1);

  IF v_row.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_building_not_found');
  END IF;

  RETURN jsonb_build_object(
    'ok', true,
    'support_whatsapp', COALESCE(v_support, '201021950445'),
    'building', public.saas_building_to_json(v_row)
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_register_building(
  p_name text,
  p_city text DEFAULT ''::text,
  p_apts_count integer DEFAULT 12,
  p_admin_pass text DEFAULT ''::text,
  p_instapay_phone text DEFAULT ''::text,
  p_instapay_url text DEFAULT ''::text,
  p_manager_whatsapp text DEFAULT ''::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_name text := trim(COALESCE(p_name, ''));
  v_city text := trim(COALESCE(p_city, ''));
  v_pass text := trim(COALESCE(p_admin_pass, ''));
  v_apts integer := GREATEST(1, LEAST(50, COALESCE(p_apts_count, 12)));
  v_insta_phone text := trim(COALESCE(p_instapay_phone, ''));
  v_insta_url text := trim(COALESCE(p_instapay_url, ''));
  v_wa text := trim(COALESCE(p_manager_whatsapp, ''));
  v_alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  v_code text;
  v_i integer;
  v_building public.buildings;
  v_cur_month integer := EXTRACT(MONTH FROM CURRENT_DATE)::integer;
  v_cur_year integer := EXTRACT(YEAR FROM CURRENT_DATE)::integer;
BEGIN
  IF char_length(v_name) = 0 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_empty_message');
  END IF;
  IF char_length(v_pass) < 4 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_pass_too_short');
  END IF;

  LOOP
    v_code := 'MBN-';
    FOR v_i IN 1..4 LOOP
      v_code := v_code || substr(v_alphabet, 1 + floor(random() * length(v_alphabet))::integer, 1);
    END LOOP;
    EXIT WHEN NOT EXISTS (SELECT 1 FROM public.buildings WHERE upper(code) = v_code);
  END LOOP;

  INSERT INTO public.buildings (
    code, name, city, apts_count, admin_password, instapay_phone, instapay_url,
    manager_whatsapp, base_emergency_fund, announcement, require_apt_pass_on_open,
    subscription_status, trial_ends_at
  )
  VALUES (
    v_code, v_name, v_city, v_apts, v_pass, v_insta_phone, v_insta_url,
    v_wa, 0, '', true, 'trial', now() + interval '30 days'
  )
  RETURNING * INTO v_building;

  INSERT INTO public.building_months (
    building_id, month_num, year_num, water, elec, elev, clean, for_emerg,
    apts_count, due_day, is_deleted
  )
  VALUES (
    v_building.id, v_cur_month, v_cur_year, 0, 0, 0, 0, 0,
    v_apts, 10, false
  );

  INSERT INTO public.building_apartments (building_id, apt_num, display_name, passcode)
  SELECT v_building.id, gs, '', ''
  FROM generate_series(1, v_apts) AS gs
  ON CONFLICT (building_id, apt_num) DO NOTHING;

  INSERT INTO public.building_contacts (building_id, name, role_desc, phone, is_deleted)
  VALUES
    (v_building.id, 'طوارئ الغاز الطبيعي', 'الخط الساخن 24 ساعة', '129', false),
    (v_building.id, 'طوارئ الكهرباء', 'الخط الساخن للأعطال', '121', false);

  RETURN jsonb_build_object(
    'ok', true,
    'building_id', v_building.id,
    'code', v_building.code,
    'building', public.saas_building_to_json(v_building)
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_update_building_profile(
  p_building_id integer,
  p_admin_pass text,
  p_name text,
  p_city text DEFAULT ''::text,
  p_instapay_phone text DEFAULT ''::text,
  p_instapay_url text DEFAULT ''::text,
  p_manager_whatsapp text DEFAULT ''::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_real_pass text;
  v_clean_name text := trim(COALESCE(p_name, ''));
BEGIN
  SELECT admin_password INTO v_real_pass FROM public.buildings WHERE id = p_building_id;
  IF v_real_pass IS NULL OR v_real_pass <> trim(COALESCE(p_admin_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;
  IF char_length(v_clean_name) = 0 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_empty_message');
  END IF;

  UPDATE public.buildings
  SET name = v_clean_name,
      city = trim(COALESCE(p_city, '')),
      instapay_phone = trim(COALESCE(p_instapay_phone, '')),
      instapay_url = trim(COALESCE(p_instapay_url, '')),
      manager_whatsapp = trim(COALESCE(p_manager_whatsapp, ''))
  WHERE id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_ensure_current_month(p_building_id integer)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_cur_month integer := EXTRACT(MONTH FROM CURRENT_DATE)::integer;
  v_cur_year integer := EXTRACT(YEAR FROM CURRENT_DATE)::integer;
  v_last_month integer;
  v_last_year integer;
  v_last_apts integer;
  v_last_elev numeric;
  v_last_clean numeric;
  v_last_due integer;
  v_b_apts integer;
BEGIN
  SELECT apts_count INTO v_b_apts FROM public.buildings WHERE id = p_building_id;
  IF v_b_apts IS NULL THEN
    RETURN;
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.building_months
    WHERE building_id = p_building_id
      AND month_num = v_cur_month
      AND year_num = v_cur_year
      AND is_deleted = false
  ) THEN
    RETURN;
  END IF;

  SELECT month_num, year_num, apts_count, elev, clean, due_day
  INTO v_last_month, v_last_year, v_last_apts, v_last_elev, v_last_clean, v_last_due
  FROM public.building_months
  WHERE building_id = p_building_id AND is_deleted = false
  ORDER BY year_num DESC, month_num DESC
  LIMIT 1;

  IF v_last_month IS NULL OR (v_cur_year * 12 + v_cur_month) > (v_last_year * 12 + v_last_month) THEN
    INSERT INTO public.building_months (
      building_id, month_num, year_num, water, elec, elev, clean, for_emerg,
      apts_count, due_day, is_deleted
    )
    VALUES (
      p_building_id, v_cur_month, v_cur_year, 0, 0,
      COALESCE(v_last_elev, 0), COALESCE(v_last_clean, 0), 0,
      COALESCE(v_last_apts, v_b_apts, 12), COALESCE(v_last_due, 10), false
    );
  END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_get_apartment_names(p_building_id integer)
RETURNS TABLE(apt_num integer, display_name text)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  SELECT a.apt_num, a.display_name
  FROM public.building_apartments a
  WHERE a.building_id = p_building_id
  ORDER BY a.apt_num;
$function$;

CREATE OR REPLACE FUNCTION public.saas_get_apartments_passcode_status(p_building_id integer)
RETURNS TABLE(apt_num integer, has_passcode boolean)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  SELECT a.apt_num, (a.passcode IS NOT NULL AND length(trim(a.passcode)) > 0) AS has_passcode
  FROM public.building_apartments a
  WHERE a.building_id = p_building_id
  ORDER BY a.apt_num;
$function$;

CREATE OR REPLACE FUNCTION public.saas_verify_apartment_passcode(
  p_building_id integer,
  p_apt_num integer,
  p_passcode text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_expected text;
BEGIN
  SELECT passcode INTO v_expected
  FROM public.building_apartments
  WHERE building_id = p_building_id AND apt_num = p_apt_num;

  IF v_expected IS NULL OR length(trim(v_expected)) = 0 OR trim(COALESCE(p_passcode, '')) <> v_expected THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_apt_pass');
  END IF;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_set_initial_apartment_passcode(
  p_building_id integer,
  p_apt_num integer,
  p_passcode text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_clean text := trim(COALESCE(p_passcode, ''));
  v_existing text;
BEGIN
  IF length(v_clean) < 4 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_pass_too_short');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.buildings WHERE id = p_building_id) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_building_not_found');
  END IF;

  SELECT passcode INTO v_existing
  FROM public.building_apartments
  WHERE building_id = p_building_id AND apt_num = p_apt_num;

  IF v_existing IS NOT NULL AND length(trim(v_existing)) > 0 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_pass_already_set');
  END IF;

  INSERT INTO public.building_apartments (building_id, apt_num, passcode)
  VALUES (p_building_id, p_apt_num, v_clean)
  ON CONFLICT (building_id, apt_num) DO UPDATE
  SET passcode = v_clean;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_verify_apt_and_record_payment(
  p_building_id integer,
  p_month_id integer,
  p_apt_num integer,
  p_passcode text,
  p_receipt_url text DEFAULT NULL::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_expected text;
  v_require_pass boolean;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.building_months
    WHERE id = p_month_id AND building_id = p_building_id AND is_deleted = false
  ) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_payment_failed');
  END IF;

  SELECT COALESCE(require_apt_pass_on_open, true) INTO v_require_pass
  FROM public.buildings
  WHERE id = p_building_id;

  IF COALESCE(v_require_pass, true) THEN
    SELECT passcode INTO v_expected
    FROM public.building_apartments
    WHERE building_id = p_building_id AND apt_num = p_apt_num;

    IF v_expected IS NULL OR v_expected <> trim(COALESCE(p_passcode, '')) THEN
      RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_apt_pass');
    END IF;
  END IF;

  INSERT INTO public.building_payments (building_id, month_id, apt_num, receipt_url, is_cancelled)
  VALUES (p_building_id, p_month_id, p_apt_num, NULLIF(trim(COALESCE(p_receipt_url, '')), ''), false)
  ON CONFLICT (month_id, apt_num) DO UPDATE
  SET receipt_url = EXCLUDED.receipt_url,
      paid_at = now(),
      is_cancelled = false;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_verify_apt_and_cancel_payment(
  p_building_id integer,
  p_month_id integer,
  p_apt_num integer,
  p_passcode text DEFAULT ''::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_expected text;
  v_require_pass boolean;
  v_receipt_url text;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.building_months
    WHERE id = p_month_id AND building_id = p_building_id AND is_deleted = false
  ) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_cancel_failed');
  END IF;

  SELECT COALESCE(require_apt_pass_on_open, true) INTO v_require_pass
  FROM public.buildings
  WHERE id = p_building_id;

  IF COALESCE(v_require_pass, true) THEN
    SELECT passcode INTO v_expected
    FROM public.building_apartments
    WHERE building_id = p_building_id AND apt_num = p_apt_num;

    IF v_expected IS NULL OR v_expected <> trim(COALESCE(p_passcode, '')) THEN
      RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_apt_pass');
    END IF;
  END IF;

  SELECT receipt_url INTO v_receipt_url
  FROM public.building_payments
  WHERE building_id = p_building_id AND month_id = p_month_id AND apt_num = p_apt_num;

  UPDATE public.building_payments
  SET is_cancelled = true,
      receipt_url = NULL
  WHERE building_id = p_building_id AND month_id = p_month_id AND apt_num = p_apt_num;

  RETURN jsonb_build_object('ok', true, 'receipt_url', COALESCE(v_receipt_url, ''));
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_submit_feedback_with_passcode(
  p_building_id integer,
  p_type text,
  p_message text,
  p_apt_num integer,
  p_passcode text,
  p_author_label text DEFAULT NULL::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
  v_display text;
BEGIN
  SELECT passcode, display_name INTO v_pass, v_display
  FROM public.building_apartments
  WHERE building_id = p_building_id AND apt_num = p_apt_num;

  IF v_pass IS NULL OR length(trim(v_pass)) = 0 OR v_pass <> trim(COALESCE(p_passcode, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_apt_pass');
  END IF;

  INSERT INTO public.feedback_posts (building_id, type, message, author_label, is_deleted)
  VALUES (
    p_building_id,
    p_type,
    p_message,
    COALESCE(NULLIF(trim(v_display), ''), NULLIF(trim(COALESCE(p_author_label, '')), ''), 'شقة ' || p_apt_num),
    false
  );

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_record_page_view(
  p_building_id integer,
  p_visitor_id text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  IF p_visitor_id IS NULL OR length(trim(p_visitor_id)) = 0 THEN
    RETURN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.buildings WHERE id = p_building_id) THEN
    RETURN;
  END IF;
  INSERT INTO public.page_views (building_id, visitor_id)
  VALUES (p_building_id, left(trim(p_visitor_id), 120));
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_register_push_token(
  p_building_id integer,
  p_token text,
  p_apt_num integer DEFAULT NULL::integer,
  p_is_admin boolean DEFAULT false,
  p_platform text DEFAULT 'web'::text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  IF p_token IS NULL OR length(trim(p_token)) < 10 THEN
    RETURN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.buildings WHERE id = p_building_id) THEN
    RETURN;
  END IF;

  INSERT INTO public.building_push_tokens (building_id, token, apt_num, is_admin, platform, updated_at)
  VALUES (p_building_id, trim(p_token), p_apt_num, COALESCE(p_is_admin, false), COALESCE(NULLIF(trim(p_platform), ''), 'web'), now())
  ON CONFLICT (building_id, token) DO UPDATE
  SET apt_num = COALESCE(EXCLUDED.apt_num, public.building_push_tokens.apt_num),
      is_admin = EXCLUDED.is_admin OR public.building_push_tokens.is_admin,
      platform = EXCLUDED.platform,
      updated_at = now();
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_get_app_notifications(
  p_building_id integer,
  p_admin_pass text DEFAULT NULL::text,
  p_apt_num integer DEFAULT NULL::integer
)
RETURNS SETOF public.app_notifications
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_real_pass text;
  v_is_admin boolean := false;
BEGIN
  SELECT admin_password INTO v_real_pass FROM public.buildings WHERE id = p_building_id;
  IF v_real_pass IS NOT NULL AND p_admin_pass IS NOT NULL AND trim(p_admin_pass) = v_real_pass THEN
    v_is_admin := true;
  END IF;

  IF v_is_admin THEN
    RETURN QUERY
      SELECT *
      FROM public.app_notifications
      WHERE building_id = p_building_id
        AND is_archived = false
      ORDER BY created_at DESC
      LIMIT 60;
  ELSE
    RETURN QUERY
      SELECT *
      FROM public.app_notifications
      WHERE building_id = p_building_id
        AND is_archived = false
        AND (
          audience = 'all'
          OR (audience = 'apartments' AND p_apt_num IS NOT NULL AND p_apt_num = ANY(target_apt_nums))
        )
      ORDER BY created_at DESC
      LIMIT 60;
  END IF;
END;
$function$;

-- -----------------------------------------------------------------------------
-- Admin Tenant-Scoped RPCs
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.saas_admin_get_apartments(
  p_building_id integer,
  p_admin_pass text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_admin_pass text;
  v_rows jsonb;
BEGIN
  SELECT admin_password INTO v_admin_pass FROM public.buildings WHERE id = p_building_id;
  IF v_admin_pass IS NULL OR v_admin_pass <> trim(COALESCE(p_admin_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'apt_num', a.apt_num,
    'display_name', a.display_name,
    'passcode', a.passcode
  ) ORDER BY a.apt_num), '[]'::jsonb) INTO v_rows
  FROM public.building_apartments a
  WHERE a.building_id = p_building_id;

  RETURN jsonb_build_object('ok', true, 'apartments', v_rows);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_update_apartment(
  p_building_id integer,
  p_admin_pass text,
  p_apt_num integer,
  p_display_name text,
  p_passcode text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_admin_pass text;
  v_clean_pass text := trim(COALESCE(p_passcode, ''));
  v_clean_name text := COALESCE(NULLIF(trim(COALESCE(p_display_name, '')), ''), '');
BEGIN
  SELECT admin_password INTO v_admin_pass FROM public.buildings WHERE id = p_building_id;
  IF v_admin_pass IS NULL OR v_admin_pass <> trim(COALESCE(p_admin_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  INSERT INTO public.building_apartments (building_id, apt_num, display_name, passcode)
  VALUES (p_building_id, p_apt_num, v_clean_name, v_clean_pass)
  ON CONFLICT (building_id, apt_num) DO UPDATE
  SET display_name = v_clean_name,
      passcode = v_clean_pass;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_reset_all_apartment_passcodes(
  p_building_id integer,
  p_admin_pass text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.building_apartments
  SET passcode = ''
  WHERE building_id = p_building_id AND apt_num > 0;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_change_password(
  p_building_id integer,
  p_current_pass text,
  p_new_pass text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_real_pass text;
  v_clean_new text := trim(COALESCE(p_new_pass, ''));
BEGIN
  IF char_length(v_clean_new) < 4 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_pass_too_short');
  END IF;

  SELECT admin_password INTO v_real_pass FROM public.buildings WHERE id = p_building_id;
  IF v_real_pass IS NULL OR v_real_pass <> trim(COALESCE(p_current_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.buildings
  SET admin_password = v_clean_new
  WHERE id = p_building_id;

  IF p_building_id = 1 THEN
    UPDATE public.building_settings SET admin_password = v_clean_new WHERE id = 1;
  END IF;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_update_month(
  p_building_id integer,
  p_admin_pass text,
  p_month_id integer,
  p_water numeric,
  p_elec numeric,
  p_elev numeric,
  p_clean numeric,
  p_for_emerg numeric,
  p_apts_count integer,
  p_base_emerg numeric,
  p_custom_expenses jsonb DEFAULT '[]'::jsonb,
  p_due_day integer DEFAULT 10
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_admin_pass text;
  v_apts integer := GREATEST(1, LEAST(50, COALESCE(p_apts_count, 13)));
BEGIN
  SELECT admin_password INTO v_admin_pass FROM public.buildings WHERE id = p_building_id;
  IF v_admin_pass IS NULL OR v_admin_pass <> trim(COALESCE(p_admin_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.building_months
  SET water = p_water,
      elec = p_elec,
      elev = p_elev,
      clean = p_clean,
      for_emerg = p_for_emerg,
      apts_count = v_apts,
      custom_expenses = COALESCE(p_custom_expenses, '[]'::jsonb),
      due_day = GREATEST(0, LEAST(31, COALESCE(p_due_day, 10)))
  WHERE id = p_month_id AND building_id = p_building_id AND is_deleted = false;

  UPDATE public.buildings
  SET base_emergency_fund = p_base_emerg,
      apts_count = v_apts
  WHERE id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_add_next_month(
  p_building_id integer,
  p_admin_pass text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_admin_pass text;
  v_last_month integer;
  v_last_year integer;
  v_last_apts integer;
  v_last_elev numeric;
  v_last_clean numeric;
  v_last_due integer;
  v_b_apts integer;
  v_next_month integer;
  v_next_year integer;
BEGIN
  SELECT admin_password, apts_count INTO v_admin_pass, v_b_apts
  FROM public.buildings WHERE id = p_building_id;

  IF v_admin_pass IS NULL OR v_admin_pass <> trim(COALESCE(p_admin_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  SELECT month_num, year_num, apts_count, elev, clean, due_day
  INTO v_last_month, v_last_year, v_last_apts, v_last_elev, v_last_clean, v_last_due
  FROM public.building_months
  WHERE building_id = p_building_id AND is_deleted = false
  ORDER BY year_num DESC, month_num DESC
  LIMIT 1;

  IF v_last_month IS NULL THEN
    v_next_month := EXTRACT(MONTH FROM CURRENT_DATE)::integer;
    v_next_year := EXTRACT(YEAR FROM CURRENT_DATE)::integer;
  ELSIF v_last_month = 12 THEN
    v_next_month := 1;
    v_next_year := v_last_year + 1;
  ELSE
    v_next_month := v_last_month + 1;
    v_next_year := v_last_year;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.building_months
    WHERE building_id = p_building_id
      AND month_num = v_next_month
      AND year_num = v_next_year
      AND is_deleted = false
  ) THEN
    INSERT INTO public.building_months (
      building_id, month_num, year_num, water, elec, elev, clean, for_emerg,
      apts_count, due_day, is_deleted
    )
    VALUES (
      p_building_id, v_next_month, v_next_year, 0, 0,
      COALESCE(v_last_elev, 0), COALESCE(v_last_clean, 0), 0,
      COALESCE(v_last_apts, v_b_apts, 12), COALESCE(v_last_due, 10), false
    );
  END IF;

  RETURN jsonb_build_object('ok', true, 'month_num', v_next_month, 'year_num', v_next_year);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_delete_month(
  p_building_id integer,
  p_admin_pass text,
  p_month_id integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
  v_count integer;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM public.building_months
  WHERE building_id = p_building_id AND is_deleted = false;

  IF v_count <= 1 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_cannot_delete_last_month');
  END IF;

  UPDATE public.building_months
  SET is_deleted = true
  WHERE id = p_month_id AND building_id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_cancel_payment(
  p_building_id integer,
  p_admin_pass text,
  p_month_id integer,
  p_apt_num integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_admin_pass text;
BEGIN
  SELECT admin_password INTO v_admin_pass FROM public.buildings WHERE id = p_building_id;
  IF v_admin_pass IS NULL OR v_admin_pass <> trim(COALESCE(p_admin_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.building_payments
  SET is_cancelled = true,
      receipt_url = NULL
  WHERE building_id = p_building_id AND month_id = p_month_id AND apt_num = p_apt_num;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_add_extra_charge(
  p_building_id integer,
  p_admin_pass text,
  p_month_id integer,
  p_apt_nums integer[],
  p_amount numeric,
  p_reason text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
  v_apt integer;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.building_months
    WHERE id = p_month_id AND building_id = p_building_id AND is_deleted = false
  ) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_submit_failed');
  END IF;

  FOREACH v_apt IN ARRAY p_apt_nums LOOP
    INSERT INTO public.building_extra_charges (building_id, month_id, apt_num, amount, reason, is_deleted)
    VALUES (p_building_id, p_month_id, v_apt, p_amount, p_reason, false);
  END LOOP;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_delete_extra_charge(
  p_building_id integer,
  p_admin_pass text,
  p_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.building_extra_charges
  SET is_deleted = true
  WHERE id = p_id AND building_id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_delete_all_extra_charges(
  p_building_id integer,
  p_admin_pass text,
  p_month_id integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.building_extra_charges
  SET is_deleted = true
  WHERE month_id = p_month_id AND building_id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_add_emergency_tx(
  p_building_id integer,
  p_admin_pass text,
  p_amount numeric,
  p_reason text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  INSERT INTO public.emergency_transactions (building_id, amount, reason, is_deleted)
  VALUES (p_building_id, p_amount, p_reason, false);

  UPDATE public.buildings
  SET base_emergency_fund = GREATEST(0, COALESCE(base_emergency_fund, 0) - p_amount)
  WHERE id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_delete_emergency_tx(
  p_building_id integer,
  p_admin_pass text,
  p_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
  v_amount numeric;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  SELECT amount INTO v_amount
  FROM public.emergency_transactions
  WHERE id = p_id AND building_id = p_building_id AND is_deleted = false;

  IF v_amount IS NOT NULL THEN
    UPDATE public.emergency_transactions
    SET is_deleted = true
    WHERE id = p_id AND building_id = p_building_id;

    UPDATE public.buildings
    SET base_emergency_fund = COALESCE(base_emergency_fund, 0) + v_amount
    WHERE id = p_building_id;
  END IF;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_set_announcement(
  p_building_id integer,
  p_admin_pass text,
  p_announcement text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.buildings
  SET announcement = COALESCE(p_announcement, '')
  WHERE id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_set_require_apt_pass_on_open(
  p_building_id integer,
  p_admin_pass text,
  p_enabled boolean
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.buildings
  SET require_apt_pass_on_open = COALESCE(p_enabled, true)
  WHERE id = p_building_id;

  RETURN jsonb_build_object('ok', true, 'enabled', COALESCE(p_enabled, true));
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_set_utility_receipt(
  p_building_id integer,
  p_admin_pass text,
  p_month_id integer,
  p_utility text,
  p_receipt_url text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  IF p_utility = 'water' THEN
    UPDATE public.building_months
    SET water_receipt_url = COALESCE(p_receipt_url, '')
    WHERE id = p_month_id AND building_id = p_building_id;
  ELSIF p_utility = 'elec' THEN
    UPDATE public.building_months
    SET elec_receipt_url = COALESCE(p_receipt_url, '')
    WHERE id = p_month_id AND building_id = p_building_id;
  ELSE
    RETURN jsonb_build_object('ok', false, 'error', 'err_submit_failed');
  END IF;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_update_feedback_status(
  p_building_id integer,
  p_admin_pass text,
  p_id bigint,
  p_status text,
  p_admin_reply text DEFAULT NULL::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.feedback_posts
  SET status = COALESCE(p_status, 'pending'),
      admin_reply = p_admin_reply
  WHERE id = p_id AND building_id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_delete_feedback(
  p_building_id integer,
  p_admin_pass text,
  p_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.feedback_posts
  SET is_deleted = true
  WHERE id = p_id AND building_id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_delete_building_contact(
  p_building_id integer,
  p_admin_pass text,
  p_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.building_contacts
  SET is_deleted = true
  WHERE id = p_id AND building_id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_get_page_view_stats(
  p_building_id integer,
  p_admin_pass text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pass text;
  v_total bigint;
  v_unique bigint;
  v_today bigint;
  v_week bigint;
BEGIN
  SELECT admin_password INTO v_pass FROM public.buildings WHERE id = p_building_id;
  IF v_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) <> v_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  SELECT
    COUNT(*),
    COUNT(DISTINCT visitor_id),
    COUNT(*) FILTER (WHERE created_at >= date_trunc('day', now())),
    COUNT(*) FILTER (WHERE created_at >= now() - interval '7 days')
  INTO v_total, v_unique, v_today, v_week
  FROM public.page_views
  WHERE building_id = p_building_id;

  RETURN jsonb_build_object(
    'ok', true,
    'total_views', COALESCE(v_total, 0),
    'unique_visitors', COALESCE(v_unique, 0),
    'today_views', COALESCE(v_today, 0),
    'week_views', COALESCE(v_week, 0)
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_get_push_apt_nums(
  p_building_id integer,
  p_admin_pass text
)
RETURNS integer[]
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_real_pass text;
  v_apts integer[];
BEGIN
  SELECT admin_password INTO v_real_pass FROM public.buildings WHERE id = p_building_id;
  IF v_real_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) IS DISTINCT FROM v_real_pass THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT COALESCE(array_agg(DISTINCT apt_num ORDER BY apt_num), '{}'::integer[])
  INTO v_apts
  FROM public.building_push_tokens
  WHERE building_id = p_building_id AND apt_num IS NOT NULL;

  RETURN COALESCE(v_apts, '{}'::integer[]);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_admin_delete_app_notification(
  p_building_id integer,
  p_admin_pass text,
  p_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_real_pass text;
BEGIN
  SELECT admin_password INTO v_real_pass FROM public.buildings WHERE id = p_building_id;
  IF v_real_pass IS NULL OR trim(COALESCE(p_admin_pass, '')) IS DISTINCT FROM v_real_pass THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_admin_pass');
  END IF;

  UPDATE public.app_notifications
  SET is_archived = true
  WHERE id = p_id AND building_id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

-- -----------------------------------------------------------------------------
-- Platform Owner Super Admin RPCs
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.saas_super_list_buildings(p_super_pass text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_real_pass text;
  v_buildings jsonb;
  v_total integer;
  v_active integer;
  v_trial integer;
  v_suspended integer;
  v_total_apts integer;
  v_total_views bigint;
BEGIN
  SELECT super_admin_password INTO v_real_pass FROM public.platform_settings WHERE id = 1;
  IF v_real_pass IS NULL OR v_real_pass <> trim(COALESCE(p_super_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_super_pass');
  END IF;

  SELECT
    COUNT(*),
    COUNT(*) FILTER (WHERE subscription_status = 'active'),
    COUNT(*) FILTER (WHERE subscription_status = 'trial'),
    COUNT(*) FILTER (WHERE subscription_status = 'suspended'),
    COALESCE(SUM(apts_count), 0)
  INTO v_total, v_active, v_trial, v_suspended, v_total_apts
  FROM public.buildings;

  SELECT COUNT(*) INTO v_total_views FROM public.page_views;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'building', public.saas_building_to_json(b),
    'months_count', (
      SELECT COUNT(*) FROM public.building_months m
      WHERE m.building_id = b.id AND m.is_deleted = false
    ),
    'payments_count', (
      SELECT COUNT(*) FROM public.building_payments p
      WHERE p.building_id = b.id AND p.is_cancelled = false
    ),
    'views_count', (
      SELECT COUNT(*) FROM public.page_views pv
      WHERE pv.building_id = b.id
    )
  ) ORDER BY b.id ASC), '[]'::jsonb)
  INTO v_buildings
  FROM public.buildings b;

  RETURN jsonb_build_object(
    'ok', true,
    'buildings', v_buildings,
    'stats', jsonb_build_object(
      'total_buildings', COALESCE(v_total, 0),
      'active_buildings', COALESCE(v_active, 0),
      'trial_buildings', COALESCE(v_trial, 0),
      'suspended_buildings', COALESCE(v_suspended, 0),
      'total_apts', COALESCE(v_total_apts, 0),
      'total_views', COALESCE(v_total_views, 0)
    )
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_super_update_subscription(
  p_super_pass text,
  p_building_id integer,
  p_status text,
  p_extend_days integer DEFAULT NULL::integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_real_pass text;
  v_clean_status text := trim(COALESCE(p_status, ''));
  v_building public.buildings;
BEGIN
  SELECT super_admin_password INTO v_real_pass FROM public.platform_settings WHERE id = 1;
  IF v_real_pass IS NULL OR v_real_pass <> trim(COALESCE(p_super_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_super_pass');
  END IF;

  IF v_clean_status NOT IN ('trial', 'active', 'suspended') THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_submit_failed');
  END IF;

  IF p_building_id = 1 AND v_clean_status = 'suspended' THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_submit_failed');
  END IF;

  SELECT * INTO v_building FROM public.buildings WHERE id = p_building_id;
  IF v_building.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_building_not_found');
  END IF;

  UPDATE public.buildings
  SET subscription_status = v_clean_status,
      trial_ends_at = CASE
        WHEN v_clean_status = 'trial' AND COALESCE(p_extend_days, 0) > 0
          THEN GREATEST(now(), COALESCE(trial_ends_at, now())) + make_interval(days => p_extend_days)
        ELSE trial_ends_at
      END,
      subscription_ends_at = CASE
        WHEN v_clean_status = 'active' AND COALESCE(p_extend_days, 0) > 0
          THEN GREATEST(now(), COALESCE(subscription_ends_at, now())) + make_interval(days => p_extend_days)
        WHEN v_clean_status = 'active' AND subscription_ends_at IS NULL
          THEN now() + interval '30 days'
        ELSE subscription_ends_at
      END
  WHERE id = p_building_id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_super_reset_building_admin_pass(
  p_super_pass text,
  p_building_id integer,
  p_new_pass text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_real_pass text;
  v_clean_new text := trim(COALESCE(p_new_pass, ''));
BEGIN
  SELECT super_admin_password INTO v_real_pass FROM public.platform_settings WHERE id = 1;
  IF v_real_pass IS NULL OR v_real_pass <> trim(COALESCE(p_super_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_super_pass');
  END IF;

  IF char_length(v_clean_new) < 4 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_pass_too_short');
  END IF;

  UPDATE public.buildings SET admin_password = v_clean_new WHERE id = p_building_id;
  IF p_building_id = 1 THEN
    UPDATE public.building_settings SET admin_password = v_clean_new WHERE id = 1;
  END IF;

  RETURN jsonb_build_object('ok', true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.saas_super_change_password(
  p_current_super_pass text,
  p_new_super_pass text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_real_pass text;
  v_clean_new text := trim(COALESCE(p_new_super_pass, ''));
BEGIN
  IF char_length(v_clean_new) < 4 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_pass_too_short');
  END IF;

  SELECT super_admin_password INTO v_real_pass FROM public.platform_settings WHERE id = 1;
  IF v_real_pass IS NULL OR v_real_pass <> trim(COALESCE(p_current_super_pass, '')) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'err_wrong_super_pass');
  END IF;

  UPDATE public.platform_settings
  SET super_admin_password = v_clean_new,
      updated_at = now()
  WHERE id = 1;

  RETURN jsonb_build_object('ok', true);
END;
$function$;
