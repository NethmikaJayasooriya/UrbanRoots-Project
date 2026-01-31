import 'package:flutter/material.dart';
import 'screens/garden_creation/garden_basics_screen.dart'; 

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
        primaryColor: const Color(0xFF2ECC71),
        scaffoldBackgroundColor: const Color(0xFF121413),
      ),
      home: const GardenBasicsScreen(), 
    );
  }
}