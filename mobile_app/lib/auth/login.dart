import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'user_1.dart';

// Color constants
const Color screenBg = Color(0xFF0F1115);
const Color fieldBg = Color(0xFF1A1D23);
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
      backgroundColor: screenBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Login to your\naccount",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                _GlowTextField(
                  hint: "Email",
                  controller: _emailController,
                ),
                const SizedBox(height: 16),

                // Password field
                _GlowTextField(
                  hint: "Password",
                  obscure: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 10),

                // Error message
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                const SizedBox(height: 20),

                // Login button
                _PrimaryButton(
                  text: "Login",
                  onPressed: () {
                    setState(() {
                      if (_emailController.text == "nethmi@gmail.com" &&
                          _passwordController.text == "nethu") {
                        _errorMessage = null;

                        // Navigate to UserProfile1
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserProfile1 ()),
                        );
                      } else {
                        _errorMessage = "Email or password is incorrect";
                      }
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/forgot_pass');
                    },
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Divider
                const _DividerText(),
                const SizedBox(height: 20),

                // Social login buttons
                const _SocialButton(
                  text: "Continue with Google",
                  icon: FontAwesomeIcons.google,
                ),
                const SizedBox(height: 16),
                const _SocialButton(
                  text: "Continue with Facebook",
                  icon: Icons.facebook_outlined,
                ),
                const SizedBox(height: 132),

                // Sign up link
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: const TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/sign_up');
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Glow TextField
class _GlowTextField extends StatefulWidget {
  final String hint;
  final bool obscure;
  final TextEditingController controller;

  const _GlowTextField({
    required this.hint,
    required this.controller,
    this.obscure = false,
  });

  @override
  State<_GlowTextField> createState() => _GlowTextFieldState();
}

class _GlowTextFieldState extends State<_GlowTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color: glowGreen,
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ]
            : [],
        border: Border.all(
          color: _isFocused ? glowGreen : Colors.transparent,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

// Primary Button
class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
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
}

// Divider
class _DividerText extends StatelessWidget {
  const _DividerText();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "or continue with",
            style: TextStyle(color: Colors.white54),
          ),
        ),
        Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }
}

// Social Button
class _SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;

  const _SocialButton({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: fieldBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
