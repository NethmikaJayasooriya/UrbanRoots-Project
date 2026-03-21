import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// OTP service that connects to the NestJS backend API.
class OtpService {
  // Use localhost for Web, 192.168.1.5 for physical phone / emulator
  static const String _baseUrl = kIsWeb ? 'http://127.0.0.1:3000' : 'http://192.168.1.5:3000';

  /// Requests an OTP from the backend based on the specific auth flow.
  /// [flow] can be 'login', 'signup', or 'forgot_password'.
  static Future<String> requestOtp(String email, String flow) async {
    try {
      // FIX: Changed from 'otp/' to 'auth/' to match AuthController
      String endpoint = '$_baseUrl/auth/'; 
      if (flow == 'login') {
        endpoint += 'login-otp';
      } else if (flow == 'signup') {
        endpoint += 'signup-otp';
      } else if (flow == 'forgot_password') {
        endpoint += 'forgot-password-otp';
      } else {
        throw Exception('Invalid OTP flow');
      }

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim()}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "OTP sent successfully";
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Failed to generate OTP';
        print('Backend OTP error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Network error generating OTP: $e');
      throw Exception('Could not connect to backend: $e');
    }
  }

  /// Verifies the user-entered OTP.
  /// If [uid] and [provider] are provided, the backend will sync/create the Firestore user.
  static Future<bool> verifyOtp({
    required String email, 
    required String enteredOtp,
    String? uid,
    String? provider,
  }) async {
    try {
      final body = {
        'email': email.trim(),
        'otp': enteredOtp.trim(),
        if (uid != null) 'uid': uid,
        if (provider != null) 'provider': provider,
      };

      final response = await http.post(
        // FIX: Changed to '/auth/verify-otp'
        Uri.parse('$_baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'OTP verification failed';
        print('Backend OTP verification error: $errorMsg');
        return false; 
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      throw Exception('Failed to verify OTP: $e');
    }
  }

  /// Resets the user's password via the backend after OTP verification.
  static Future<bool> resetPassword({
    required String email,
    required String enteredOtp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        // FIX: Changed to '/auth/reset-password'
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'otp': enteredOtp.trim(),
          'newPassword': newPassword,
        }),
      );

      print('Reset password response status: ${response.statusCode}');
      print('Reset password response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      // Parse the error message from backend
      final errorBody = jsonDecode(response.body);
      final errorMsg = errorBody['message'] ?? 'Password reset failed';
      print('Reset password backend error: $errorMsg');
      throw Exception(errorMsg);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  /// Clears stored OTP data for the given email.
  static Future<void> clearOtp(String email) async {
    // Handled by the backend internally. No-op here.
  }

  /// Marks the user as persistently logged in / OTP verified.
  /// Merged to use the 'is_otp_verified' key from the AI branch.
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    // Setting both keys just in case other parts of the app rely on the old key
    await prefs.setBool('is_otp_verified', value);
    await prefs.setBool('isLoggedIn', value);
  }

  /// Checks if the user has a persistent login session or verified OTP.
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Check for either the old key or the new AI branch key
      bool isOtpVerified = prefs.getBool('is_otp_verified') ?? false;
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      return isOtpVerified || isLoggedIn;
    } catch (e) {
      return false;
    }
  }
}