import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/supabase_manager.dart';
import '../common/role_router.dart';
import 'supabase_auth_screen.dart';
import 'role_selection.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  String? _role;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    if (!SupabaseManager.isReady) {
      setState(() => _loading = false);
      return;
    }
    final auth = SupabaseManager.client.auth;
    // Listen to auth state changes
    auth.onAuthStateChange.listen((event) async {
      await _resolveRouting();
    });
    await _resolveRouting();
  }

  Future<void> _resolveRouting() async {
    if (!mounted) return;
    if (!SupabaseManager.isReady) {
      setState(() => _loading = false);
      return;
    }
    final session = SupabaseManager.client.auth.currentSession;
    if (session == null) {
      setState(() => _loading = false);
      return;
    }
    final userId = session.user.id;
    final data = await SupabaseManager.client
        .from('users')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    _role = data != null ? (data['role'] as String?) : null;
    if (!mounted) return;
    if (_role == null) {
      setState(() => _loading = false);
      return;
    }
    Navigator.pushReplacementNamed(context, routeForRole(_role!));
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseManager.isReady) {
      return const SupabaseNotConfiguredScreen();
    }
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final session = SupabaseManager.client.auth.currentSession;
    if (session == null) {
      return const SupabaseAuthScreen();
    }
    if (_role == null) {
      return RoleSelectionScreen(
        onRoleSelected: (role) async {
          final user = SupabaseManager.client.auth.currentUser;
          if (user != null) {
            await SupabaseManager.client.from('users').upsert({'id': user.id, 'role': role.toLowerCase()});
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, routeForRole(role.toLowerCase()));
          }
        },
      );
    }
    // Fallback
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class SupabaseNotConfiguredScreen extends StatelessWidget {
  const SupabaseNotConfiguredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Required')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Supabase not configured', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Run the app with your Supabase URL and Anon Key:'),
            SizedBox(height: 8),
            SelectableText('flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY'),
            SizedBox(height: 16),
            Text('Optional: add --dart-define=GEMINI_API_KEY=AIza...'),
            SizedBox(height: 24),
            Text('You can still explore UI screens from the splash -> onboarding flow.'),
          ],
        ),
      ),
    );
  }
}
