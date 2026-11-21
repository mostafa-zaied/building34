/// إعدادات الربط مع Supabase.
/// الوضع الافتراضي (Production) يعمل تلقائياً عند الرفع على Firebase Hosting.
/// للتشغيل على بيئة التجربة (Staging) محلياً:
/// flutter run -d chrome --dart-define-from-file=env.staging.json
class AppConfig {
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static bool get isStaging => appEnv == 'staging';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qxsctwnctwqzsdmtsssw.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_MFftSMzqB7Smzs5wjPEK8Q_9pR9VxI4',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
