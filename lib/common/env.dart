class Env {
  // Provide via --dart-define or edit defaults below when you have them
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const geminiModel = String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-1.5-flash');
}
