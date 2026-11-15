/// إعدادات الربط مع Supabase.
/// تم ربط المشروع ببيانات Supabase الخاصة بك.
class AppConfig {
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
