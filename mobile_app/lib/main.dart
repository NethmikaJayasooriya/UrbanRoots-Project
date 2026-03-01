import 'package:flutter/material.dart';
import 'features/profile/screens/profile_screen.dart';

void main() {
  runApp(const UrbanRootsApp());
}

class UrbanRootsApp extends StatelessWidget {
  const UrbanRootsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanRoots',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),
      home: const ProfileScreen(),
    );
  }
}
