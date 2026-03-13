import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/services/otp_service.dart';
import 'setup_profile_screen.dart';
import 'reset_password_screen.dart';

/// Verification screen that handles OTP input for both signup and forgot-password flows.
///
/// Pass [email] (the user's email) and [flow] ('signup' or 'forgot_password')
/// to control what happens after successful verification.
class VerificationScreen extends StatefulWidget {
  final String email;
  final String flow; // 'signup' or 'forgot_password'

  const VerificationScreen({super.key, this.email = '', this.flow = 'signup'});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  bool _isLoading = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  // Inline error for OTP
  String _otpError = '';

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _nextField(String value, int index) {
    if (value.length == 1 && index < 3) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
  }

  Future<void> _verifyOtpCode() async {
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length < 4) {
      setState(() => _otpError = "Please enter the full 4-digit code");
      return;
    }

    setState(() {
      _isLoading = true;
      _otpError = '';
    });

    try {
      final isValid = await OtpService.verifyOtp(widget.email, otp);

      if (!isValid) {
        setState(() {
          _otpError = "Invalid or expired code. Please try again.";
          _isLoading = false;
        });
        return;
      }

      // OTP verified successfully — clear stored OTP
      await OtpService.clearOtp(widget.email);

      if (!mounted) return;

      if (widget.flow == 'signup') {
        // Save persistent login state
        await OtpService.setLoggedIn(true);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SetupProfileScreen()),
          (route) => false,
        );
      } else if (widget.flow == 'forgot_password') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(email: widget.email),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _otpError = "Verification failed. Please try again.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;

    final otp = await OtpService.generateOtp(widget.email);

    if (!mounted) return;

    setState(() {
      _otpError = ''; // clear error when new OTP sent
    });

    // Show the OTP in a dialog (simulate email delivery)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title: Text(
          "Your OTP Code",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Your verification code is: $otp\n\n(In production, this would be sent to your email)",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );

    // Start cooldown timer (30 seconds)
    setState(() => _resendCooldown = 30);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayEmail = widget.email.isNotEmpty ? widget.email : "your email";

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
          child: Padding(
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

                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: AppColors.primaryGreen,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Check your email",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "We sent a code to $displayEmail",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // OTP input boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 65,
                      height: 65,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.danger,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.danger,
                              width: 2,
                            ),
                          ),
                          errorText: _otpError.isNotEmpty
                              ? ' '
                              : null, // Trigger red border
                        ),
                        onChanged: (value) => _nextField(value, index),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtpCode,
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
                            "Verify Code",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Resend OTP link
                Center(
                  child: GestureDetector(
                    onTap: _resendCooldown > 0 ? null : _resendOtp,
                    child: RichText(
                      text: TextSpan(
                        text: "Haven't got the email yet? ",
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: _resendCooldown > 0
                                ? "Resend in ${_resendCooldown}s"
                                : "Resend email",
                            style: GoogleFonts.poppins(
                              color: _resendCooldown > 0
                                  ? Colors.white30
                                  : AppColors.primaryGreen,
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
}
