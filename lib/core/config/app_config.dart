class AppConfig {
  AppConfig._();

  // --- SUPABASE ---
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // --- POWERSYNC ---
  static const String powerSyncUrl = String.fromEnvironment(
    'POWERSYNC_ENDPOINT_URL',
    defaultValue: '',
  );

  static const String powerSyncApiKey = String.fromEnvironment(
    'POWERSYNC_API_KEY',
    defaultValue: '',
  );

  // --- APP SECRETS ---
  static const String uftPassword = String.fromEnvironment(
    'UFT_PASSWORD',
    defaultValue: '',
  );

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Helper to check if configuration is valid
  static bool get isValid =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}
