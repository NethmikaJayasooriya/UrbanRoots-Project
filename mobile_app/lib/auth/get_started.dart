import 'package:flutter/material.dart';
import 'splash_screen.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  void initState() {
    super.initState();
    _redirectToSplash();
  }
  Future<void> _redirectToSplash() async {
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      ),
    );
  }



@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with slight upward offset
                Transform.translate(
                  offset: const Offset(-20, -45),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 529,
                    width: 629,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 180), // space below logo
                //  Spinner
                const CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF00FF9D),
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