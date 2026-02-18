import 'package:flutter/material.dart';
import 'verification_page.dart';
class ForgotPasswordApp extends StatelessWidget {
  const ForgotPasswordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Enter your email so we can send a reset link",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // Email TextField with Glow Effect
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1A1D23),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color(0xFF00FF9D), // glow green
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Send Code Button with Navigation
              GestureDetector(
                onTap: () {
                  // Navigate to verification page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VerificationPage(),
                    ),
                  );
                },
                child: _button("Send code"),
              ),

              const SizedBox(height: 50),

              //Back to Login
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Navigate back
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 14,
                  color: Colors.white70,
                ),
                label: const Text(
                  "Back to Login",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Button
  Widget _button(String text) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF00E676),
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
    );
  }
}
