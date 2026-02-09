import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Transform.translate(
              offset: const Offset(-20, -20), // move left by 20, up by 20
              child: Image.asset(
                'assets/logo.png',
                height: 450,
                width: 529,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 15),

            // Title - move up slightly
            Transform.translate(
              offset: const Offset(-10, -70), // move up by 10
              child: const Text(
                'Grow together for a greener tomorrow',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontFamily: 'FiraSans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Subtitle
      Transform.translate(
        offset: const Offset(-10, -70), // move up by 10
        child: const Text(
              'Learn to grow plants step by step. IoT sensors help your plants thrive while you nurture urban gardens.',

              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 24,
                fontFamily: 'FiraSans',
              ),
            ),
      ),
            const SizedBox(height: 40),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent[400],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.black87, fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Sign-up Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.greenAccent),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Sign-up',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Help text
            const Text(
              'Looking for help?',
              style: TextStyle(color: Colors.white38, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
