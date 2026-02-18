import 'package:flutter/material.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

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
                "Enter Verification Code",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "We have sent a 4-digit code to your email. Please enter it below.",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Code TextField
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),


                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: const TextStyle(color: Colors.white, letterSpacing: 10),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: '', // hides the maxLength counter
                    hintText: "----",
                    hintStyle: const TextStyle(color: Colors.white38, letterSpacing: 10),
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
                        color: Color(0xFF00E676),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Verify Button
              _button(context, "Verify"),

              const SizedBox(height: 20),

              // Resend Code
              TextButton(
                onPressed: () {
                  //Resend code logic
                },
                child: const Text(
                  "Resend Code",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom Button
  Widget _button(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/create_new_pass');
      },
      child: Container(
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
      ),
    );
  }
}
