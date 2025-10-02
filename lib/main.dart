
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/supabase_manager.dart';
import 'auth/auth_gate.dart';
import 'dashboard/organizer_dashboard.dart';
import 'dashboard/attendee_dashboard.dart';
import 'dashboard/vendor_dashboard.dart';
import 'dashboard/sponsor_dashboard.dart';
import 'common/theme.dart';
import 'qr_attendance/qr_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseManager.initIfAvailable();
  runApp(ProviderScope(child: const SyncSphereApp()));
}

class SyncSphereApp extends StatelessWidget {
  const SyncSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyncSphere',
      theme: syncSphereTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthGate(),
        '/organizer': (context) => const OrganizerDashboard(),
        '/attendee': (context) => const AttendeeDashboard(),
        '/vendor': (context) => const VendorDashboard(),
        '/sponsor': (context) => const SponsorDashboard(),
        '/qr-scan': (context) => const QRScannerScreen(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/syncsphere_logo.json', width: 180, repeat: false),
            const SizedBox(height: 32),
            const Text(
              'SyncSphere',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          _OnboardingPage(
            title: 'Welcome to SyncSphere',
            description: 'Unify Organizers, Attendees, Vendors, and Sponsors in one platform.',
            lottieAsset: 'assets/lottie/syncsphere_logo.json',
          ),
          _OnboardingPage(
            title: 'AI Assistance',
            description: 'Get instant help and smart event navigation with AI.',
            lottieAsset: 'assets/lottie/syncsphere_logo.json',
          ),
          _OnboardingPage(
            title: 'Gamification & Analytics',
            description: 'Earn points, badges, and view real-time ROI analytics.',
            lottieAsset: 'assets/lottie/syncsphere_logo.json',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
        label: const Text('Get Started'),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String lottieAsset;
  const _OnboardingPage({required this.title, required this.description, required this.lottieAsset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(lottieAsset, width: 180, repeat: true),
          const SizedBox(height: 32),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(description, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
 
