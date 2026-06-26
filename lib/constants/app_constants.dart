class AppConstants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://haubjiclkskymrpuuqph.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhhdWJqaWNsa3NreW1ycHV1cXBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3NzgxMTcsImV4cCI6MjA5NDM1NDExN30.A8CqXytC6X3pjn7eSoqf6vGtpoTqSXPxb_9i5GtywUk',
  );

  static const String claveInicial = 'Ecuador2026';
  static const String bucketVacunaciones = 'vacunaciones';
}
