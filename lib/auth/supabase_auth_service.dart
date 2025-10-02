import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/supabase_manager.dart';

class SupabaseAuthService {
  static SupabaseClient get _client => SupabaseManager.client;

  static Future<String> signInWithEmail(String email, String password) async {
    if (!SupabaseManager.isReady) {
      throw Exception('Supabase not configured');
    }
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    final user = res.user;
    if (user == null) throw Exception('Invalid credentials');
    return user.id;
  }

  static Future<String> signUpWithEmail(String email, String password) async {
    if (!SupabaseManager.isReady) {
      throw Exception('Supabase not configured');
    }
    final res = await _client.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user == null) throw Exception('Sign up failed');
    // By default email confirmation might be required depending on Supabase settings.
    return user.id;
  }

  static Future<void> setUserRole(String userId, String role, {String? email, String? name}) async {
    if (!SupabaseManager.isReady) return;
    await _client.from('users').upsert({
      'id': userId,
      'role': role.toLowerCase(),
      if (email != null) 'email': email,
      if (name != null) 'name': name,
    });
  }

  static Future<String?> getUserRole(String userId) async {
    if (!SupabaseManager.isReady) return null;
    final data = await _client.from('users').select('role').eq('id', userId).maybeSingle();
    if (data == null) return null;
    return data['role'] as String?;
  }
}
