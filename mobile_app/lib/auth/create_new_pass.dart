import 'package:flutter/material.dart';

class CreateNewPassScreen extends StatelessWidget {
  const CreateNewPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreateNewPass(),
    );
  }
}

class CreateNewPass extends StatelessWidget {
  const CreateNewPass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Create New Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            _field("Password"),
            const SizedBox(height: 15),
            _field("Confirm Password"),
            const SizedBox(height: 25),
            _button(context, "Reset Password"),
          ],
        ),
      ),
    );
  }

  /// Password TextField with Glow Effect
  Widget _field(String hint) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
    ),
    child: TextField(
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1A1D23), // same as email field
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color(0xFF00FF9D), // green glow
            width: 2,
          ),
        ),
      ),
    ),
  );

  // button
  Widget _button(BuildContext context, String text) => GestureDetector(
    onTap: () {
      // Show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset successfully!"),
          duration: Duration(seconds: 1), // after the password reset msg is shown the page redirects back to the login page
        ),
      );

      // Redirect after SnackBar disappears
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushNamed(context, '/login');// Go back to login page
      });
    },



    child: Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF00FF9D), // glow green button
        borderRadius: BorderRadius.circular(30),

      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
