import 'package:flutter/material.dart';
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
        primaryColor: const Color(0xFF00E676),
        scaffoldBackgroundColor: const Color(0xFF07160F), 
      ),
      
      home: const MainNavigationWrapper(), 
    );
  }
}