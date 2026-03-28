import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/core/api_constants.dart';

class ApiService {
  static String get baseUrl => ApiConstants.baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-user-id': FirebaseAuth.instance.currentUser?.uid ?? '',
      };

  // ================= PROFILE =================

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(Uri.parse('$baseUrl/profile/me'), headers: _headers).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Request timed out while loading profile.'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  static Future<String> uploadImage(String filePath) async {
    final uri = Uri.parse('$baseUrl/products/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', filePath));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['imageUrl'];
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    String? profileImageUrl,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/profile/me'),
      headers: _headers,
      body: jsonEncode({
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  // ================= PREFERENCES =================

  static Future<Map<String, dynamic>> getPreferences() async {
    final response = await http.get(Uri.parse('$baseUrl/preferences/me'), headers: _headers).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Request timed out while loading preferences.'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load preferences: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/preferences/me'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update preferences: ${response.body}');
    }
  }

  // ================= NOTIFICATIONS =================

  static Future<List<dynamic>> getNotifications() async {
    final response = await http.get(Uri.parse('$baseUrl/notifications/me'), headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load notifications: ${response.body}');
    }
  }

  static Future<void> markNotificationRead(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: _headers,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to mark notification read: ${response.body}');
    }
  }

  static Future<void> markAllNotificationsRead() async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/me/read-all'),
      headers: _headers,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to mark all notifications read: ${response.body}',
      );
    }
  }

  // ================= REVIEWS =================

  static Future<Map<String, dynamic>?> getMyReview() async {
    final response = await http.get(Uri.parse('$baseUrl/reviews/me'), headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty || response.body == 'null') {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded == null) return null;

      return decoded as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load review: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> submitReview({
    required int stars,
    required String feedbackText,
  }) async {
    final trimmed = feedbackText.trim();

    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: _headers,
      body: jsonEncode({
        'stars': stars,
        'hasFeedback': trimmed.isNotEmpty,
        'feedbackText': trimmed.isEmpty ? null : trimmed,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to submit review: ${response.body}');
    }
  }

  // ================= TERMS =================

  static Future<Map<String, dynamic>> getCurrentTerms() async {
    final response = await http.get(Uri.parse('$baseUrl/terms/current'), headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load terms: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> acceptTerms(String version) async {
    final response = await http.post(
      Uri.parse('$baseUrl/terms/accept'),
      headers: _headers,
      body: jsonEncode({'version': version}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to accept terms: ${response.body}');
    }
  }

  // ================= STREAKS =================

  static Future<Map<String, dynamic>> getMyStreak() async {
    final response = await http.get(Uri.parse('$baseUrl/streaks/me'), headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load streak: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> completeTodayStreak() async {
    final response = await http.post(
      Uri.parse('$baseUrl/streaks/complete-today'),
      headers: _headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to complete streak today: ${response.body}');
    }
  }

  // ================= DATA EXPORT =================

  static Future<Map<String, dynamic>> createExportRequest(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/data-export/requests'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create export request: ${response.body}');
    }
  }

  static Future<List<dynamic>> getExportRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/data-export/requests/me'),
      headers: _headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load export requests: ${response.body}');
    }
  }

  // ================= SUPPORT =================

  static Future<Map<String, dynamic>> createSupportTicket({
    String? category,
    required String subject,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/support/tickets'),
      headers: _headers,
      body: jsonEncode({
        'category': category,
        'subject': subject,
        'message': message,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create support ticket: ${response.body}');
    }
  }

  static Future<List<dynamic>> getSupportTickets() async {
    final response = await http.get(Uri.parse('$baseUrl/support/tickets/me'), headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load support tickets: ${response.body}');
    }
  }

  static Future<List<dynamic>> getSupportFaqs() async {
    final response = await http.get(Uri.parse('$baseUrl/support/faqs'), headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load FAQs: ${response.body}');
    }
  }

  static Future<List<dynamic>> searchSupportFaqs(String query) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final response = await http.get(
      Uri.parse('$baseUrl/support/faqs/search?q=$encodedQuery'),
      headers: _headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to search FAQs: ${response.body}');
    }
  }

  // ================= SELLER HUB =================

  static Future<Map<String, dynamic>?> getSeller() async {
    final response = await http.get(Uri.parse('$baseUrl/seller'), headers: _headers).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Request timed out while loading seller dashboard.'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty || response.body == 'null') {
        return null;
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load seller: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> startSeller() async {
    final response = await http.post(Uri.parse('$baseUrl/seller/start'), headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to start seller onboarding: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> completeSellerIdentity() async {
    final response = await http.post(Uri.parse('$baseUrl/seller/identity'), headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to complete identity step: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateSellerShop({
    required String shopName,
    required String shopDescription,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/seller/shop'),
      headers: _headers,
      body: jsonEncode({
        'shop_name': shopName,
        'shop_description': shopDescription,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update shop details: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> setSellerPayout({
    required String method,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/seller/payout'),
      headers: _headers,
      body: jsonEncode({'method': method}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to set payout method: ${response.body}');
    }
  }

  // ================= SUBSCRIPTIONS =================

  static Future<Map<String, dynamic>> startSubscriptionMembership({
    required String selectedPlan,
    required String paymentMethod,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subscriptions/start-membership'),
      headers: _headers,
      body: jsonEncode({
        'selectedPlan': selectedPlan,
        'paymentMethod': paymentMethod,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to start membership: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getSubscription() async {
    final response = await http.get(Uri.parse('$baseUrl/subscriptions/me'), headers: _headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load subscription: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateSubscription(
    String selectedPlan,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/subscriptions/me'),
      headers: _headers,
      body: jsonEncode({'selectedPlan': selectedPlan}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update subscription: ${response.body}');
    }
  }
}
