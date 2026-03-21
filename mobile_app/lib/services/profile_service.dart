import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Handles communication with the backend API to retrieve and update user profile information.

class ProfileService {
  static const String _baseUrl = kIsWeb ? 'http://127.0.0.1:3000' : 'http://192.168.1.5:3000';

  static Future<bool> updateProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/user/$uid/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Failed to update profile: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }
}
