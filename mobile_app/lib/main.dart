import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- ADDED THIS IMPORT!
import 'package:mobile_app/services/otp_service.dart';
import 'firebase_options.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/setup_profile_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'services/auth_service.dart';
import 'screens/garden_creation/garden_intro_screen.dart';
import 'screens/dashboard/nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase for Image Storage
  await Supabase.initialize(
    url: 'https://lbdyfmhetidvimwawvmi.supabase.co', // Make sure to paste your URL!
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxiZHlmbWhldGlkdmltd2F3dm1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5NjE3NzUsImV4cCI6MjA4ODUzNzc3NX0.a0PspBWet3hxAsbHlfnS5IlCZd3jsZwoTx-_0lI_ZnE', // Make sure to paste your Anon Key!
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Urban Roots',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00E676),
        scaffoldBackgroundColor: const Color(0xFF07160F),
      ),
      home: const SplashScreenWrapper(),
    );
  }
}

// Wrapper to handle splash screen + navigation
class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateFromSplash();
  }

  void _navigateFromSplash() async {
    // Show splash for at least 4 seconds
    await Future.delayed(const Duration(seconds: 4));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User logged in via Firebase, but needs OTP verification
      final loggedIn = await OtpService.isLoggedIn().catchError((_) => false);
      if (loggedIn) {
        // OTP already verified, check if already onboarded to skip setup profile
        final isOnboarded = await AuthService.checkIsOnboarded(user.uid);
        if (isOnboarded) {
          _goToScreen(const MainNavigationWrapper());
        } else {
          _goToScreen(const SetupProfileScreen());
        }
      } else {
        // User is in Firebase but hasn't verified OTP yet - sign them out
        await FirebaseAuth.instance.signOut();
        _goToScreen(const LoginScreen());
      }
    } else {
      // No user logged in
      _goToScreen(const LoginScreen());
    }
  }

  void _goToScreen(Widget screen) {
    // FIX: This prevents the "unmounted context" crash you saw in the logs!
    // It checks if the widget is still active before trying to navigate.
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}