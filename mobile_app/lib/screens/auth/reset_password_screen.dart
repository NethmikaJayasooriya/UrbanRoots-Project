import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/services/otp_service.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/screens/dashboard/nav_bar.dart';
import 'setup_profile_screen.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isPassVisible = false;
  bool _isConfirmVisible = false;
  bool _isLoading = false;

  void _resetPassword() async {
    final password = _passController.text.trim();
    final confirmPassword = _confirmPassController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showError("Please fill in both fields.");
      return;
    }

    if (password.length < 8) {
      _showError("Password must be at least 8 characters.");
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use Backend to reset password directly via OTP
      final success = await OtpService.resetPassword(
        email: widget.email,
        enteredOtp: widget.otp,
        newPassword: password,
      );

      if (!success) {
        throw Exception("Failed to reset password. The link might have expired.");
      }

      // Auto-login with Firebase using the new password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: password,
      );

      // Set local persistent state
      await OtpService.setLoggedIn(true);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final isOnboarded = await AuthService.checkIsOnboarded(user.uid);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Password reset successfully! You are now logged in.",
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              backgroundColor: AppColors.primaryGreen,
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
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
            }
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      print('ResetPasswordScreen FirebaseAuth error: $e');
      _showError(e.message ?? "Failed to reset password.");
    } catch (e) {
      print('ResetPasswordScreen error: $e');
      _showError("Something went wrong: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F221A), AppColors.backgroundColor],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
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

                Text(
                  "Create new password 🔒",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your new password must be unique from those previously used.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 40),

                _buildLabel("New Password"),
                _buildTextField(
                  controller: _passController,
                  hint: "Enter new password",
                  isVisible: _isPassVisible,
                  onToggle: () =>
                      setState(() => _isPassVisible = !_isPassVisible),
                ),
                const SizedBox(height: 20),

                _buildLabel("Confirm Password"),
                _buildTextField(
                  controller: _confirmPassController,
                  hint: "Confirm new password",
                  isVisible: _isConfirmVisible,
                  onToggle: () =>
                      setState(() => _isConfirmVisible = !_isConfirmVisible),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: AppColors.primaryGreen.withOpacity(0.4),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            "Reset Password",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Colors.white54,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white54,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
