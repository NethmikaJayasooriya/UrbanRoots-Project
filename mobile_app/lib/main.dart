import 'package:flutter/material.dart';
// 1. IMPORT YOUR NAV BAR WRAPPER HERE
import 'screens/dashboard/nav_bar.dart'; 

void main() {
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
        primaryColor: const Color(0xFF00E676), // Use your Neon Green
        scaffoldBackgroundColor: const Color(0xFF07160F), // Use your bgColor
      ),
      // 2. CHANGE THIS: Start with the Wrapper, not the Garden screen
      home: const MainNavigationWrapper(), 
    );
  }
}