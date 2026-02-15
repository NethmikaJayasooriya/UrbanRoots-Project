import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Color fieldBg = Color(0xFF112A24);
const Color primaryGreen = Color(0xFF00E676);
const Color glowGreen = Color(0xFF00FF9D);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Login to your\naccount",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              _glowOnFocusTextField("Email",
                  controller: _emailController),

              const SizedBox(height: 20),

              _glowOnFocusTextField(
                "Password",
                controller: _passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 10),

              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),

              const SizedBox(height: 15),

              _primaryButton(context, "Login"),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot password?",
                  style: TextStyle(color: Colors.green),
                ),
              ),

              const SizedBox(height: 40),

              const Center(
                child: Text(
                  "— or continue with —",
                  style: TextStyle(color: Colors.white54),
                ),
              ),

              const SizedBox(height: 25),

              _socialButton(
                  "Continue with Google", FontAwesomeIcons.google),

              const SizedBox(height: 18),

              _socialButton(
                  "Continue with Facebook", Icons.facebook_outlined),

              const SizedBox(height: 140),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style:
                    const TextStyle(color: Colors.white70),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(
                                context, '/sign_up');
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowOnFocusTextField(
      String hint, {
        bool isPassword = false,
        required TextEditingController controller,
      }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(30),
              boxShadow: hasFocus
                  ? [
                BoxShadow(
                  color: glowGreen,
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ]
                  : [],
              border: Border.all(
                color: hasFocus
                    ? glowGreen
                    : Colors.transparent,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                const TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _primaryButton(
      BuildContext context, String text) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (_emailController.text !=
                "test@example.com" ||
                _passwordController.text !=
                    "123456") {
              _errorMessage =
              "Email or password is incorrect";
            } else {
              _errorMessage = null;

              Navigator.pushNamed(
                  context, '/home'); // fixed route
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _socialButton(
      String text, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
              context, '/signup');
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: fieldBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
