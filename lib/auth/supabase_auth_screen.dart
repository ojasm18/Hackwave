import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/supabase_manager.dart';
import '../common/role_router.dart';
import 'role_selection.dart';

class SupabaseAuthScreen extends StatefulWidget {
  const SupabaseAuthScreen({super.key});

  @override
  State<SupabaseAuthScreen> createState() => _SupabaseAuthScreenState();
}

class _SupabaseAuthScreenState extends State<SupabaseAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _selectedRole;

  Future<void> _signIn() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await SupabaseManager.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = res.user;
      if (user == null) throw Exception('Invalid credentials');
      final profile = await SupabaseManager.client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      final role = profile?['role'] as String?;
      if (!mounted) return;
      if (role == null) {
        setState(() { _error = 'No role found. Please pick a role.'; });
      } else {
        Navigator.pushReplacementNamed(context, routeForRole(role));
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _signUp() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      if (_selectedRole == null) {
        setState(() { _error = 'Please select a role.'; });
        return;
      }
      final res = await SupabaseManager.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = res.user;
      if (user == null) throw Exception('Sign up failed');
      await SupabaseManager.client.from('users').upsert({
        'id': user.id,
        'email': _emailController.text.trim(),
        'role': _selectedRole!.toLowerCase(),
      });
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, routeForRole(_selectedRole!));
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseManager.isReady) {
      return const Scaffold(
        body: Center(child: Text('Supabase not configured')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In / Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              const Text('Pick your role (for sign up):'),
              const SizedBox(height: 8),
              RoleSelectionInline(
                selected: _selectedRole,
                onSelected: (r) => setState(() => _selectedRole = r),
              ),
              const SizedBox(height: 24),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              if (!_isLoading) ...[
                ElevatedButton.icon(
                  onPressed: _signIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _signUp,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Sign Up'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class RoleSelectionInline extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelected;
  const RoleSelectionInline({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final roles = const [
      {'label': 'Organizer', 'icon': Icons.event},
      {'label': 'Attendee', 'icon': Icons.person},
      {'label': 'Vendor', 'icon': Icons.store},
      {'label': 'Sponsor', 'icon': Icons.business},
    ];
    return Wrap(
      spacing: 8,
      children: roles.map((r) {
        final label = r['label'] as String;
        final icon = r['icon'] as IconData;
        final isSelected = label == selected;
        return ChoiceChip(
          label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)]),
          selected: isSelected,
          onSelected: (_) => onSelected(label),
        );
      }).toList(),
    );
  }
}
