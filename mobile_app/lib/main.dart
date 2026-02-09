import 'package:flutter/material.dart';
import 'auth/splash_screen.dart'; // import your splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Pages',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(), 
    );
  }
}
