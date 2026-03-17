import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// OTP service that connects to the NestJS backend API.
class OtpService {
  // Use localhost for Web, 10.0.2.2 for Android emulator
  static const String _baseUrl = kIsWeb ? 'http://localhost:3000/auth' : 'http://10.0.2.2:3000/auth';



  /// Requests an OTP from the backend based on the specific auth flow.
  /// [flow] can be 'login', 'signup', or 'forgot_password'.
  static Future<String> requestOtp(String email, String flow) async {
    try {
      String endpoint = '$_baseUrl/';
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
        body: jsonEncode({'email': email}),
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
        'email': email,
        'otp': enteredOtp,
        if (uid != null) 'uid': uid,
        if (provider != null) 'provider': provider,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Network error verifying OTP: $e');
      return false;
    }
  }

  /// Clears stored OTP data for the given email.
  static Future<void> clearOtp(String email) async {
    // Handled by the backend internally. No-op here.
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
