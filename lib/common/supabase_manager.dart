import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

class SupabaseManager {
  static bool _initialized = false;

  static bool get isReady => _initialized;

  static Future<void> initIfAvailable() async {
    // Initialize only when env values are present
    if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) {
      _initialized = false;
      return;
    }
    if (_initialized) return;
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
