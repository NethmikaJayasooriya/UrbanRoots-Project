import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'login_screen.dart';
import 'setup_profile_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>(); 
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const SetupProfileScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF07160F);
    const neonGreen = Color(0xFF00E676);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Text("Create Account", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 10),
                    const Icon(Icons.spa, color: neonGreen, size: 28),
                  ],
                ),
                Text("Join the green revolution today.", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54)),
                const SizedBox(height: 40),

                _buildLabel("Email"),
                _buildTextField(
                  controller: _emailController, 
                  hint: "Enter your email", 
                  icon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email is required";
                    if (!value.contains('@')) return "Please enter a valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                _buildLabel("Password"),
                _buildTextField(
                  controller: _passController,
                  hint: "Create a password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password is required";
                    if (value.length < 8) return "Must be at least 8 characters";
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: neonGreen,
                      checkColor: Colors.black,
                      side: const BorderSide(color: Colors.white54),
                      onChanged: (val) => setState(() => _agreedToTerms = val!),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: "I agree to the ",
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                          children: [
                            TextSpan(text: "Terms of Service", style: GoogleFonts.poppins(color: neonGreen, fontWeight: FontWeight.bold)),
                            const TextSpan(text: " and "),
                            TextSpan(text: "Privacy Policy", style: GoogleFonts.poppins(color: neonGreen, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _agreedToTerms ? _handleSignUp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonGreen,
                      disabledBackgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text("Sign Up", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: _agreedToTerms ? Colors.black : Colors.white24)),
                  ),
                ),

                const SizedBox(height: 30),
                
               
                _buildDivider(),
                const SizedBox(height: 30),
                _buildSocialButton("Continue with Google", FontAwesomeIcons.google),
                const SizedBox(height: 15),
                _buildSocialButton("Continue with Facebook", FontAwesomeIcons.facebookF),
               

                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: GoogleFonts.poppins(color: Colors.white54)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                      child: Text("Log In", style: GoogleFonts.poppins(color: neonGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }

  // Divider Widget 
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white10)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Or continue with", style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
        ),
        const Expanded(child: Divider(color: Colors.white10)),
      ],
    );
  }

  // Social Button Widget
  Widget _buildSocialButton(String text, IconData icon) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 20, top: 0, bottom: 0,
              child: Center(child: FaIcon(icon, color: Colors.white, size: 20)),
            ),
            Center(
              child: Text(
                text,
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    bool isPassword = false, 
    bool isPasswordVisible = false,
    String? Function(String?)? validator,
    VoidCallback? onVisibilityToggle
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF16201B),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54, size: 20),
              onPressed: onVisibilityToggle,
            ) 
          : null,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white30),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00E676)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
      ),
    );
  }
}