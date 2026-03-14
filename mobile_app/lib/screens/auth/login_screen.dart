import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
// Ensure MainNavigationWrapper is accessible
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/otp_service.dart';
import 'package:mobile_app/screens/dashboard/nav_bar.dart';
import 'forgot_password_screen.dart';
import 'setup_profile_screen.dart';
import 'sign_up_screen.dart';
import 'verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isGoogleLoading = false;

  void _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final userCredential = await AuthService.signInWithGoogle();
      if (userCredential == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }
      debugPrint("Google sign-in user: ${userCredential.user?.email}");

      final user = userCredential.user!;
      final email = user.email;
      if (email == null) throw Exception("No email found from Google.");

      await OtpService.requestGoogleOtp(email);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(email: email, flow: 'google'),
        ),
      );
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Google sign-in failed. Please try again."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        debugPrint("Logged in user: ${userCredential.user?.email}");

        // Ask Backend to send an OTP
        await OtpService.requestOtp(email, 'login');

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(email: email, flow: 'login'),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
                const SizedBox(height: 30),

                Row(
                  children: [
                    Text(
                      "Welcome Back!",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.waving_hand,
                      color: AppColors.primaryGreen,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                _buildLabel("Email"),
                _buildTextField(
                  controller: _emailController,
                  hint: "Enter your email",
                  icon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Email is required";
                    if (!value.contains('@')) return "Invalid email format";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel("Password"),
                _buildTextField(
                  controller: _passwordController,
                  hint: "Enter your password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onVisibilityToggle: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Password is required";
                    return null;
                  },
                ),

                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primaryGreen,
                            checkColor: Colors.black,
                            side: const BorderSide(color: Colors.white54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) =>
                                setState(() => _rememberMe = val!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Remember me",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Log In",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                _buildDivider(),
                const SizedBox(height: 30),

                _buildSocialButton(
                  "Continue with Google",
                  FontAwesomeIcons.google,
                  onTap: _handleGoogleSignIn,
                  isLoading: _isGoogleLoading,
                ),

                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: GoogleFonts.poppins(color: Colors.white54),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
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
    VoidCallback? onVisibilityToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceColor,
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white30),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        errorStyle: GoogleFonts.poppins(color: AppColors.danger, fontSize: 12),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white10)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "Or continue with",
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white10)),
      ],
    );
  }

  Widget _buildSocialButton(
    String text,
    IconData icon, {
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(child: FaIcon(icon, color: Colors.white, size: 20)),
            ),
            Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
