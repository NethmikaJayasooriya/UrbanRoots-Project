import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/otp_service.dart';
import 'package:mobile_app/screens/dashboard/nav_bar.dart';
import 'login_screen.dart';
import 'setup_profile_screen.dart';
import 'verification_screen.dart';

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
  bool _isGoogleLoading = false;
  bool _isEmailLoading = false;

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please agree to the terms first.")),
        );
        return;
      }

      setState(() => _isEmailLoading = true);

      try {
        final email = _emailController.text.trim();
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email,
              password: _passController.text,
            );

        debugPrint("User created: ${userCredential.user?.email}");

        // trigger otp via backend
        try {
          await OtpService.requestOtp(email, 'signup');
        } catch (otpError) {
          debugPrint("OTP request failed: $otpError");
          // rollback firebase user on otp fail
          await FirebaseAuth.instance.currentUser?.delete();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send verification code: ${otpError.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (mounted) setState(() => _isEmailLoading = false);
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sign-up initiated! Verification code sent.")),
          );

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VerificationScreen(email: email, flow: 'signup'),
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = e.message ?? 'An error occurred';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already registered. Please log in instead.';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $errorMessage")),
          );
        }
      } finally {
        if (mounted) setState(() => _isEmailLoading = false);
      }
    }
  }

  void _handleGoogleSignIn() async {
    debugPrint("DEBUG: Google Sign-In button pressed");
    setState(() => _isGoogleLoading = true);
    try {
      final userCredential = await AuthService.signInWithGoogle();
      if (userCredential == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }
      debugPrint("Google sign-up user: ${userCredential.user?.email}");

      final user = userCredential.user!;
      final email = user.email;
      if (email == null) throw Exception("No email found from Google.");

      // get onboarding flag
      final isOnboarded = await AuthService.checkIsOnboarded(user.uid);
      
      // mark logged in locally
      await OtpService.setLoggedIn(true);

      if (!mounted) return;

      if (isOnboarded) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SetupProfileScreen()),
          (route) => false,
        );
      }
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Create Account",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.spa,
                      color: AppColors.primaryGreen,
                      size: 28,
                    ),
                  ],
                ),
                Text(
                  "Join the green revolution today.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
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
                    if (!value.contains('@')) return "Enter a valid email";
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
                  onVisibilityToggle: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Password is required";
                    if (value.length < 8)
                      return "Must be at least 8 characters";
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: AppColors.primaryGreen,
                      checkColor: Colors.black,
                      side: const BorderSide(color: Colors.white54),
                      onChanged: (val) => setState(() => _agreedToTerms = val!),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: "I agree to the ",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: "Terms",
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                    onPressed: _agreedToTerms && !_isEmailLoading
                        ? _handleSignUp
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isEmailLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            "Sign Up",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
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
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: GoogleFonts.poppins(color: Colors.white54),
                        children: [
                          TextSpan(
                            text: "Log In",
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

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white10)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "Or",
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
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceColor,
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white54,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
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
}
