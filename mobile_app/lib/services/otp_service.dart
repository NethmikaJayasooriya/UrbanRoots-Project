import 'package:shared_preferences/shared_preferences.dart';

class OtpService {
  // Checks if the user has completed the OTP verification step
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Default to false if the flag doesn't exist yet
      return prefs.getBool('is_otp_verified') ?? false; 
    } catch (e) {
      return false;
    }
  }

  // You can call this method after a successful OTP verification
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_otp_verified', value);
  }
}