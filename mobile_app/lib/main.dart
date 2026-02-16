import 'package:flutter/material.dart';
import 'package:splashscreen/auth/create_new_pass.dart';
import 'package:splashscreen/auth/forgot_pass.dart';
import 'package:splashscreen/auth/verification_page.dart';
import 'auth/login.dart';
import 'auth/sign_up.dart';
import 'auth/get_started.dart';
import 'auth/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStarted(),
        '/splash_screen': (context) => const SplashScreen(),
        '/login':(context)=> const LoginScreen(),
        '/sign_up': (context) => SignUpScreen(),
        '/forgot_pass' : (context)=>ForgotPasswordApp(),
        '/verification_page' : (context)=>VerificationPage(),
        '/create_new_pass': (context)=>CreateNewPass(),

      },
    );
  }
}
