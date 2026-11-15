-- ============================================================
-- Amaraty (مصاريف العمارة) - Supabase Database & Storage Setup
-- انسخ هذا الملف بالكامل وشغّله في Supabase -> SQL Editor
-- ============================================================

-- 1. جدول إعدادات العمارة (رصيد الطوارئ الأساسي + كلمة سر المدير)
CREATE TABLE IF NOT EXISTS building_settings (
  id INT PRIMARY KEY DEFAULT 1,
  base_emergency_fund NUMERIC NOT NULL DEFAULT 2550,
  admin_password TEXT NOT NULL DEFAULT 'zaied34',
  CONSTRAINT single_row CHECK (id = 1)
);

INSERT INTO building_settings (id, base_emergency_fund, admin_password)
VALUES (1, 2550, 'zaied34')
ON CONFLICT (id) DO NOTHING;

-- 2. جدول الشهور والمصاريف
CREATE TABLE IF NOT EXISTS months (
  id SERIAL PRIMARY KEY,
  month_num INT NOT NULL,
  year_num INT NOT NULL DEFAULT 2026,
  water NUMERIC NOT NULL DEFAULT 0,
  elec NUMERIC NOT NULL DEFAULT 0,
  elev NUMERIC NOT NULL DEFAULT 400,
  clean NUMERIC NOT NULL DEFAULT 240,
  for_emerg NUMERIC NOT NULL DEFAULT 0,
  apts_count INT NOT NULL DEFAULT 13,
  UNIQUE(month_num, year_num)
);

-- إضافة بيانات شهر 11 الفعلية + الشهور السابقة والأرشيف
INSERT INTO months (month_num, year_num, water, elec, elev, clean, for_emerg, apts_count)
VALUES
  (7,  2026, 1080, 1500, 400, 240, 0,   13),
  (8,  2026, 1100, 1590, 400, 240, 50,  13),
  (9,  2026, 1150, 1620, 400, 240, 100, 13),
  (10, 2026, 1210, 1700, 400, 240, 90,  13),
  (11, 2026, 1281, 1803, 400, 240, 176, 13),
  (12, 2026, 0,    0,    400, 240, 0,   13)
ON CONFLICT (month_num, year_num) DO NOTHING;

-- 3. جدول الشقق وكلمات السر (محمي ولا يمكن قراءة كلمات السر من التطبيق)
CREATE TABLE IF NOT EXISTS apartments (
  apt_num INT PRIMARY KEY,
  display_name TEXT,
  passcode TEXT NOT NULL
);

ALTER TABLE apartments ADD COLUMN IF NOT EXISTS display_name TEXT;

-- توليد كلمات سر افتراضية للشقق من 1 إلى 30 (مثلاً شقة 1 -> 1001، شقة 5 -> 1005)
INSERT INTO apartments (apt_num, passcode)
SELECT g, (1000 + g)::TEXT
FROM generate_series(1, 30) AS g
ON CONFLICT (apt_num) DO NOTHING;

-- 4. جدول المدفوعات وإيصالات التحويل
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  month_id INT NOT NULL REFERENCES months(id) ON DELETE CASCADE,
  apt_num INT NOT NULL,
  receipt_url TEXT NOT NULL,
  paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(month_id, apt_num)
);

-- ============================================================
-- 5. تفعيل الحماية (Row Level Security)
-- ============================================================
ALTER TABLE building_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE months ENABLE ROW LEVEL SECURITY;
ALTER TABLE apartments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- السماح للجميع بقراءة الشهور والمدفوعات ورصيد الطوارئ (بدون كلمة سر المدير)
DROP POLICY IF EXISTS "Public read months" ON months;
CREATE POLICY "Public read months" ON months FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public read payments" ON payments;
CREATE POLICY "Public read payments" ON payments FOR SELECT USING (true);
-- ملاحظة: نمنع القراءة المباشرة لجدول apartments و building_settings.admin_password
-- ونوفر دالة آمنة لقراءة رصيد الطوارئ فقط

CREATE OR REPLACE FUNCTION get_base_emergency_fund()
RETURNS NUMERIC
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT base_emergency_fund FROM building_settings WHERE id = 1;
$$;

-- ============================================================
-- 6. دوال السيرفر الآمنة (RPC Functions)
-- ============================================================

-- أ. التحقق من كلمة سر الشقة وتسجيل الدفع مع صورة الإيصال
CREATE OR REPLACE FUNCTION verify_apt_and_record_payment(
  p_month_id INT,
  p_apt_num INT,
  p_passcode TEXT,
  p_receipt_url TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_expected TEXT;
BEGIN
  SELECT passcode INTO v_expected FROM apartments WHERE apt_num = p_apt_num;
  IF v_expected IS NULL OR v_expected <> trim(p_passcode) THEN
    RETURN json_build_object('ok', false, 'error', 'كلمة سر الشقة غير صحيحة');
  END IF;

  IF p_receipt_url IS NULL OR length(trim(p_receipt_url)) = 0 THEN
    RETURN json_build_object('ok', false, 'error', 'صورة الإيصال مطلوبة');
  END IF;

  INSERT INTO payments (month_id, apt_num, receipt_url)
  VALUES (p_month_id, p_apt_num, p_receipt_url)
  ON CONFLICT (month_id, apt_num) DO UPDATE
  SET receipt_url = EXCLUDED.receipt_url, paid_at = NOW();

  RETURN json_build_object('ok', true);
END;
$$;

-- ب. التحقق من كلمة سر المدير وتحديث مصاريف الشهر
CREATE OR REPLACE FUNCTION admin_update_month(
  p_admin_pass TEXT,
  p_month_id INT,
  p_water NUMERIC,
  p_elec NUMERIC,
  p_elev NUMERIC,
  p_clean NUMERIC,
  p_for_emerg NUMERIC,
  p_apts_count INT,
  p_base_emerg NUMERIC
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_admin_pass TEXT;
BEGIN
  SELECT admin_password INTO v_admin_pass FROM building_settings WHERE id = 1;
  IF v_admin_pass <> trim(p_admin_pass) THEN
    RETURN json_build_object('ok', false, 'error', 'كلمة سر المسؤول غير صحيحة');
  END IF;

  UPDATE months
  SET water = p_water,
      elec = p_elec,
      elev = p_elev,
      clean = p_clean,
      for_emerg = p_for_emerg,
      apts_count = GREATEST(1, p_apts_count)
  WHERE id = p_month_id;

  UPDATE building_settings
  SET base_emergency_fund = p_base_emerg
  WHERE id = 1;

  RETURN json_build_object('ok', true);
END;
$$;

-- ج. إلغاء دفع شقة (للمدير فقط)
CREATE OR REPLACE FUNCTION admin_cancel_payment(
  p_admin_pass TEXT,
  p_month_id INT,
  p_apt_num INT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_admin_pass TEXT;
BEGIN
  SELECT admin_password INTO v_admin_pass FROM building_settings WHERE id = 1;
  IF v_admin_pass <> trim(p_admin_pass) THEN
    RETURN json_build_object('ok', false, 'error', 'كلمة سر المسؤول غير صحيحة');
  END IF;

  DELETE FROM payments WHERE month_id = p_month_id AND apt_num = p_apt_num;
  RETURN json_build_object('ok', true);
END;
$$;

-- د. قراءة أسماء الشقق للجميع (بدون كلمات السر)
CREATE OR REPLACE FUNCTION get_apartment_names()
RETURNS TABLE(apt_num INT, display_name TEXT)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT apt_num, display_name FROM apartments ORDER BY apt_num;
$$;

-- هـ. قراءة الشقق مع كلمات السر (للمدير فقط)
CREATE OR REPLACE FUNCTION admin_get_apartments(p_admin_pass TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_admin_pass TEXT;
  v_rows JSON;
BEGIN
  SELECT admin_password INTO v_admin_pass FROM building_settings WHERE id = 1;
  IF v_admin_pass <> trim(p_admin_pass) THEN
    RETURN json_build_object('ok', false, 'error', 'كلمة سر المسؤول غير صحيحة');
  END IF;

  SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) INTO v_rows
  FROM (SELECT apt_num, display_name, passcode FROM apartments ORDER BY apt_num) t;

  RETURN json_build_object('ok', true, 'apartments', v_rows);
END;
$$;

-- و. تعديل اسم الشقة وكلمة سرها (للمدير فقط)
CREATE OR REPLACE FUNCTION admin_update_apartment(
  p_admin_pass TEXT,
  p_apt_num INT,
  p_display_name TEXT,
  p_passcode TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_admin_pass TEXT;
BEGIN
  SELECT admin_password INTO v_admin_pass FROM building_settings WHERE id = 1;
  IF v_admin_pass <> trim(p_admin_pass) THEN
    RETURN json_build_object('ok', false, 'error', 'كلمة سر المسؤول غير صحيحة');
  END IF;

  IF length(trim(p_passcode)) = 0 THEN
    RETURN json_build_object('ok', false, 'error', 'كلمة سر الشقة لا يمكن أن تكون فارغة');
  END IF;

  INSERT INTO apartments (apt_num, display_name, passcode)
  VALUES (p_apt_num, NULLIF(trim(p_display_name), ''), trim(p_passcode))
  ON CONFLICT (apt_num) DO UPDATE
  SET display_name = NULLIF(trim(p_display_name), ''),
      passcode = trim(p_passcode);

  RETURN json_build_object('ok', true);
END;
$$;

-- ============================================================
-- 7. إنشاء Bucket لصور الإيصالات (Storage)
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('receipts', 'receipts', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public read receipts" ON storage.objects;
CREATE POLICY "Public read receipts"
ON storage.objects FOR SELECT
USING (bucket_id = 'receipts');

DROP POLICY IF EXISTS "Public upload receipts" ON storage.objects;
CREATE POLICY "Public upload receipts"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'receipts');

-- ============================================================
-- 8. جدول الشكاوى والتحسينات (اختياري بالاسم أو بدون اسم)
-- ============================================================
CREATE TABLE IF NOT EXISTS feedback_posts (
  id BIGSERIAL PRIMARY KEY,
  type TEXT NOT NULL CHECK (type IN ('complaint', 'improvement')),
  message TEXT NOT NULL,
  author_label TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE feedback_posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read feedback_posts" ON feedback_posts;
CREATE POLICY "Public read feedback_posts" ON feedback_posts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert feedback_posts" ON feedback_posts;
CREATE POLICY "Public insert feedback_posts" ON feedback_posts FOR INSERT WITH CHECK (true);

CREATE OR REPLACE FUNCTION admin_delete_feedback(
  p_admin_pass TEXT,
  p_id BIGINT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_admin_pass TEXT;
BEGIN
  SELECT admin_password INTO v_admin_pass FROM building_settings WHERE id = 1;
  IF v_admin_pass <> p_admin_pass THEN
    RETURN json_build_object('ok', false, 'error', 'كلمة سر المسؤول غير صحيحة');
  END IF;

  DELETE FROM feedback_posts WHERE id = p_id;
  RETURN json_build_object('ok', true);
END;
$$;

CREATE OR REPLACE FUNCTION submit_feedback_with_passcode(
  p_type TEXT,
  p_message TEXT,
  p_apt_num INT,
  p_passcode TEXT,
  p_author_label TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pass TEXT;
  v_display TEXT;
BEGIN
  SELECT passcode, display_name INTO v_pass, v_display
  FROM apartments
  WHERE apt_num = p_apt_num;

  IF v_pass IS NULL THEN
    RETURN json_build_object('ok', false, 'error', 'الشقة غير موجودة');
  END IF;

  IF v_pass <> p_passcode THEN
    RETURN json_build_object('ok', false, 'error', 'كلمة سر الشقة غير صحيحة');
  END IF;

  INSERT INTO feedback_posts (type, message, author_label)
  VALUES (
    p_type,
    p_message,
    COALESCE(NULLIF(TRIM(v_display), ''), p_author_label, 'شقة ' || p_apt_num)
  );

  RETURN json_build_object('ok', true);
END;
$$;
