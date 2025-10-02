import 'package:flutter/material.dart';
import 'role_selection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseAuthScreen extends StatefulWidget {
  const FirebaseAuthScreen({super.key});

  @override
  State<FirebaseAuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<FirebaseAuthScreen> {
  String? selectedRole;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _signInWithEmail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _storeUserRole(credential.user);
      _navigateToDashboard();
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _signUpWithEmail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _storeUserRole(credential.user);
      _navigateToDashboard();
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _signInWithGoogle() async {
    // TODO: Implement Google sign-in (requires additional setup)
    setState(() { _error = 'Google sign-in not yet implemented.'; });
  }

  Future<void> _storeUserRole(User? user) async {
    if (user == null || selectedRole == null) return;
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await doc.set({
      'email': user.email,
      'role': selectedRole,
    }, SetOptions(merge: true));
  }

  void _navigateToDashboard() {
    if (selectedRole == 'Organizer') {
      Navigator.pushReplacementNamed(context, '/organizer');
    } else if (selectedRole == 'Attendee') {
      Navigator.pushReplacementNamed(context, '/attendee');
    } else if (selectedRole == 'Vendor') {
      Navigator.pushReplacementNamed(context, '/vendor');
    } else if (selectedRole == 'Sponsor') {
      Navigator.pushReplacementNamed(context, '/sponsor');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedRole == null) {
      return RoleSelectionScreen(
        onRoleSelected: (role) {
          setState(() {
            selectedRole = role;
          });
        },
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Sign In as $selectedRole')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sign in with Google or Email/Password', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!_isLoading) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Sign In with Email'),
                onPressed: _signInWithEmail,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Sign Up with Email'),
                onPressed: _signUpWithEmail,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Sign in with Google'),
                onPressed: _signInWithGoogle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
