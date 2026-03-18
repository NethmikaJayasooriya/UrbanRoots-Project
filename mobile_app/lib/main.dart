import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app/services/otp_service.dart';
import 'firebase_options.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/setup_profile_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'services/auth_service.dart';
import 'screens/garden_creation/garden_intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      // User logged in, check OTP verification
      final loggedIn = await OtpService.isLoggedIn().catchError((_) => false);
      if (loggedIn) {
        // Check if already onboarded to skip setup profile
        final isOnboarded = await AuthService.checkIsOnboarded(user.uid);
        if (isOnboarded) {
          _goToScreen(const GardenIntroScreen());
        } else {
          _goToScreen(const SetupProfileScreen());
        }
      } else {
        _goToScreen(const VerificationScreen());
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
