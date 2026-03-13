import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Local OTP service for generating and verifying 4-digit codes.
/// Replace with real backend API calls when available.
class OtpService {
  static const int _otpLength = 4;
  static const int _expiryMinutes = 5;

  /// Generates a random 4-digit OTP and stores it locally for the given email.
  /// Returns the generated OTP string.
  static Future<String> generateOtp(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random();
    final otp = List.generate(_otpLength, (_) => random.nextInt(10)).join();
    final expiry = DateTime.now().add(const Duration(minutes: _expiryMinutes));

    await prefs.setString('otp_$email', otp);
    await prefs.setString('otp_expiry_$email', expiry.toIso8601String());

    return otp;
  }

  /// Verifies the user-entered OTP against the stored one.
  /// Returns true if valid and not expired.
  static Future<bool> verifyOtp(String email, String enteredOtp) async {
    final prefs = await SharedPreferences.getInstance();
    final storedOtp = prefs.getString('otp_$email');
    final expiryStr = prefs.getString('otp_expiry_$email');

    if (storedOtp == null || expiryStr == null) return false;

    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      // OTP has expired
      await clearOtp(email);
      return false;
    }

    return storedOtp == enteredOtp;
  }

  /// Clears stored OTP data for the given email.
  static Future<void> clearOtp(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('otp_$email');
    await prefs.remove('otp_expiry_$email');
  }

  /// Marks the user as persistently logged in.
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  /// Checks if the user has a persistent login session.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
