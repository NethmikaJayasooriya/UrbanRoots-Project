import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';

import 'package:mobile_app/core/api_constants.dart';

// otp service
class OtpService {
  // Ensure we use the shared, dynamic local baseUrl
  static String get _baseUrl => ApiConstants.baseUrl;

  // generate otp
  static Future<String> requestOtp(String email, String flow) async {
    try {
      // temp fix: updated endpoint to match auth module
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
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          'Connection timed out. Make sure the backend is running and the emulator can reach 10.0.2.2:3000.',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "OTP sent successfully";
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Failed to generate OTP';
        debugPrint('Backend OTP error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Network error generating OTP: $e');
      throw Exception('Could not connect to backend: $e');
    }
  }

  // verify otp and sync user doc
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
        // route fix
        Uri.parse('$_baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception(
          'Verification timed out. Please check your connection and try again.',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'OTP verification failed';
        debugPrint('Backend OTP verification error: $errorMsg');
        return false; 
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // password reset post-otp
  static Future<bool> resetPassword({
    required String email,
    required String enteredOtp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        // route fix
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'otp': enteredOtp.trim(),
          'newPassword': newPassword,
        }),
      );

      debugPrint('Reset password response status: ${response.statusCode}');
      debugPrint('Reset password response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      // parse backend error msg
      final errorBody = jsonDecode(response.body);
      final errorMsg = errorBody['message'] ?? 'Password reset failed';
      debugPrint('Reset password backend error: $errorMsg');
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    }
  }

  // clear otp cache
  static Future<void> clearOtp(String email) async {
    // no-op; handled by backend
  }

  // local auth persistence
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    // backcompat for legacy auth keys
    await prefs.setBool('is_otp_verified', value);
    await prefs.setBool('isLoggedIn', value);
  }

  // check active session
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // fallback check for legacy keys
      bool isOtpVerified = prefs.getBool('is_otp_verified') ?? false;
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      return isOtpVerified || isLoggedIn;
    } catch (e) {
      return false;
    }
  }
}