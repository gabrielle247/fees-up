class AppConfig {
  AppConfig._();

  // TODO: Replace with your actual Supabase URL and Anon Key
  // Ideally, use --dart-define or .env files for these secrets
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}
