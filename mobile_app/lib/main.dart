import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; // Pulls in your API keys and config
import 'screens/auth/splash_screen.dart'; 
import 'screens/dashboard/Home.dart';
import 'package:mobile_app/screens/dashboard/nav_bar.dart';
import 'package:mobile_app/screens/garden_creation/garden_intro_screen.dart';

void main() async { 
  // Required before initializing native plugins like Firebase
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Initializes Firebase using the specific platform config from your generated file
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
      title: 'Urban Roots',
      theme: ThemeData(
        brightness: Brightness.dark, 
        primaryColor: const Color(0xFF00E676),
        scaffoldBackgroundColor: const Color(0xFF07160F), 
      ),
     home: const GardenIntroScreen(), 
    );
  }
}