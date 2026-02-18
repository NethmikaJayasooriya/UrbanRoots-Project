import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart'; // Navigate back to login after success

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isPassVisible = false;
  bool _isConfirmVisible = false;

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF00E676);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F221A), Color(0xFF07160F)],
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

                Text("Create new password 🔒", style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text("Your new password must be unique from those previously used.", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60)),
                const SizedBox(height: 40),

                // New Password
                _buildLabel("New Password"),
                _buildTextField(
                  controller: _passController,
                  hint: "Enter new password",
                  isVisible: _isPassVisible,
                  onToggle: () => setState(() => _isPassVisible = !_isPassVisible),
                ),
                const SizedBox(height: 20),

                // Confirm Password
                _buildLabel("Confirm Password"),
                _buildTextField(
                  controller: _confirmPassController,
                  hint: "Confirm new password",
                  isVisible: _isConfirmVisible,
                  onToggle: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                ),

                const SizedBox(height: 40),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Success Logic -> Go to Login
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Password changed successfully!", style: GoogleFonts.poppins(color: Colors.black)),
                          backgroundColor: neonGreen,
                        )
                      );
                      
                      // Delay slightly so user sees the message
                      Future.delayed(const Duration(seconds: 1), () {
                         Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false // Clears all history
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      shadowColor: neonGreen.withOpacity(0.4),
                      elevation: 5,
                    ),
                    child: Text("Reset Password", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
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
      child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
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
        color: const Color(0xFF16201B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54, size: 20),
            onPressed: onToggle,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}