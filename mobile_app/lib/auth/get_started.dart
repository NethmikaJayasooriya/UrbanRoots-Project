import 'package:flutter/material.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F1A),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 450,
                  width: 529,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 50), // reduced space

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/splash_screen');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF161917),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(
                        color: Color(0xFF4ADE80),
                        width: 2, // optional: adjust border thickness
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
