import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TapGestureRecognizer _loginRecognizer;

  @override
  void initState() {
    super.initState();
    _loginRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushNamed(context, '/login');
      };
  }

  @override
  void dispose() {
    _loginRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Register to your\naccount",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                const _EmailField(),
                const SizedBox(height: 16),
                const _InputField(
                  hint: "Password",
                  obscure: true,
                ),
                const SizedBox(height: 16),
                const _InputField(
                  hint: "Confirm Password",
                  obscure: true,
                ),
                const SizedBox(height: 24),
                const _SignUpButton(),
                const SizedBox(height: 20),
                const _TermsRow(),
                const SizedBox(height: 30),
                const _DividerText(),
                const SizedBox(height: 20),
                const _SocialButton(
                  text: "Continue with Google",
                  icon: Icons.g_mobiledata,
                ),
                const SizedBox(height: 16),
                const _SocialButton(
                  text: "Continue with Facebook",
                  icon: Icons.facebook,
                ),
                const SizedBox(height: 60),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: "Login in",
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: _loginRecognizer,
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

// EMAIL FIELD (Glow only when focused)

class _EmailField extends StatefulWidget {
  const _EmailField();

  @override
  State<_EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<_EmailField> {
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
        borderRadius: BorderRadius.circular(30),
        boxShadow: _isFocused
            ? [
          const BoxShadow(
            color: Color(0xFF00E676),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ]
            : [],
      ),
      child: TextField(
        focusNode: _focusNode,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Email",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Color(0xFF1A1D23),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// PASSWORD FIELD

class _InputField extends StatelessWidget {
  final String hint;
  final bool obscure;

  const _InputField({required this.hint, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1A1D23),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// SIGN UP BUTTON

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E676),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {},
        child: const Text(
          "Sign up",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

// TERMS ROW

class _TermsRow extends StatefulWidget {
  const _TermsRow();

  @override
  State<_TermsRow> createState() => _TermsRowState();
}

class _TermsRowState extends State<_TermsRow> {
  bool isChecked = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          activeColor: const Color(0xFF00E676),
          onChanged: (value) {
            setState(() {
              isChecked = value!;
            });
          },
        ),
        const Expanded(
          child: Text(
            "I agree to the Terms & Conditions and Privacy",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// DIVIDER

class _DividerText extends StatelessWidget {
  const _DividerText();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "or continue with",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }
}

// SOCIAL BUTTON

class _SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;

  const _SocialButton({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1D23),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {},
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
