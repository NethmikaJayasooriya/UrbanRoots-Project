import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_app/services/otp_service.dart';
import 'firebase_options.dart';
// screens
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/setup_profile_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/dashboard/nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // init supabase
  await Supabase.initialize(
    url: 'https://lbdyfmhetidvimwawvmi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxiZHlmbWhldGlkdmltd2F3dm1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5NjE3NzUsImV4cCI6MjA4ODUzNzc3NX0.a0PspBWet3hxAsbHlfnS5IlCZd3jsZwoTx-_0lI_ZnE',
  );

  runApp(
    // provider array for app state
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
      ],
      child: const MyApp(),
    ),
  );
}

// main app root
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
        // m3 theme seeding
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

  // handles initial nav state
  void _navigateFromSplash() async {
    // temp fix: artificial delay for splash
    await Future.delayed(const Duration(seconds: 4));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // verify server state vs local firebase token
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
