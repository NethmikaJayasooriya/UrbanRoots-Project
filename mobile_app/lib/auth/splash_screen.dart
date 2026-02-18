import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(height: 5),

                // Logo
            Transform.translate( offset: const Offset(-20, -60),
              child: Image.asset(
                  'assets/logo.png',
                  height: 459,
                  width:600,
                  fit: BoxFit.contain,
                ),
            ),



                // Title
            Transform.translate( offset: const Offset(0, -120),
                child: Text(
                  'Grow together for a greener tomorrow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily: 'FiraSans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ),

                const SizedBox(height: 10),

                // Subtitle
            Transform.translate( offset: const Offset(0, -100),
                child: Text(
                  'Learn to grow plants step by step. IoT sensors help your plants thrive while you nurture urban gardens.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontFamily: 'FiraSans',
                  ),
                ),
            ),

                const SizedBox(height: 6),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.black87, fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 19),

                // Sign-up Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/sign_up');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.greenAccent),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign-up',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Looking for help?',
                  style: TextStyle(color: Colors.white38, fontSize: 16),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
