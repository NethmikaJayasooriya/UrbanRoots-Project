import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import 'firebase_options.dart';
// Auth Screens
import 'package:splashscreen/screens/auth/splash_screen.dart';
import 'package:splashscreen/screens/auth/welcome_screen.dart';
import 'package:splashscreen/screens/auth/login_screen.dart';
import 'package:splashscreen/screens/auth/sign_up_screen.dart';
import 'package:splashscreen/screens/auth/forgot_password_screen.dart';
import 'package:splashscreen/screens/auth/setup_profile_screen.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UrbanRoots',
      // Define the global theme here so you don't have to repeat colors everywhere
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF07160F), 
        primaryColor: const Color(0xFF00E676),            
        useMaterial3: true,
      ),
      // Start with the Splash Screen
      initialRoute: '/',
      routes: {
        // Auth Flow
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
         '/sign_up': (context) => const SignUpScreen(),
         '/forgot_password': (context) => const ForgotPasswordScreen(),
         '/setup_profile': (context) => const SetupProfileScreen(),
      },
    );
  }
}