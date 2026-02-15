import 'package:flutter/material.dart';

void main() {
  runApp(const SignUpApp());
}

class SignUpApp extends StatelessWidget {
  const SignUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1E1B),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Register to your account",
                style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 25),
            _field("Email"),
            const SizedBox(height: 15),
            _field("Password"),
            const SizedBox(height: 15),
            _field("Confirm Password"),
            const SizedBox(height: 25),
            _button("Sign up"),
          ],
        ),
      ),
    );
  }

  Widget _field(String hint) => TextField(
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF143C35),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  Widget _button(String text) => Container(
    width: double.infinity,
    height: 50,
    decoration: BoxDecoration(
      color: Colors.greenAccent,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold))),
  );
}
