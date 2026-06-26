class AppConstants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://TU-PROYECTO.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'TU-ANON-KEY',
  );

  static const String claveInicial = 'Ecuador2026';
  static const String bucketVacunaciones = 'vacunaciones';
}
