import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Added for state management
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_app/services/otp_service.dart';
import 'firebase_options.dart';

// Service & Model Imports
import 'services/auth_service.dart';
import 'screens/dashboard/cart_model.dart'; // Import your CartModel

// Screen Imports
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/setup_profile_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/dashboard/nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase for Image Storage
  await Supabase.initialize(
    url: 'https://lbdyfmhetidvimwawvmi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxiZHlmbWhldGlkdmltd2F3dm1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5NjE3NzUsImV4cCI6MjA4ODUzNzc3NX0.a0PspBWet3hxAsbHlfnS5IlCZd3jsZwoTx-_0lI_ZnE',
  );

  runApp(
    // Wrap the app in a MultiProvider to handle the Shopping Cart state
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
      ],
      child: const MyApp(),
    ),
  );
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
        // Applying seed color for consistent Material 3 styling
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E676),
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreenWrapper(),
    );
  }
}

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
    // Splash screen delay
    await Future.delayed(const Duration(seconds: 4));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Logic for authenticated users
      final loggedIn = await OtpService.isLoggedIn().catchError((_) => false);
      if (loggedIn) {
        final isOnboarded = await AuthService.checkIsOnboarded(user.uid);
        if (isOnboarded) {
          _goToScreen(const MainNavigationWrapper());
        } else {
          _goToScreen(const SetupProfileScreen());
        }
      } else {
        await FirebaseAuth.instance.signOut();
        _goToScreen(const LoginScreen());
      }
    } else {
      _goToScreen(const LoginScreen());
    }
  }

  void _goToScreen(Widget screen) {
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