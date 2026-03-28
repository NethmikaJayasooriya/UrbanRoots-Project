import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mobile_app/core/api_constants.dart';

// Service class for interacting with the Marketplace backend API.
// Handles product fetching, order creation, and user reviews.
class MarketplaceApi {
  static String get baseUrl => ApiConstants.baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-user-id': FirebaseAuth.instance.currentUser?.uid ?? '',
      };

  // Fetches the full catalog of available products and treatments
  static Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/marketplace/products'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  static Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/marketplace/orders'),
        headers: _headers,
        body: json.encode(orderData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['orderId'];
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  static Future<List<dynamic>> fetchReviews(String productId) async {
    try {
      final encodedId = Uri.encodeComponent(productId);
      final response = await http.get(Uri.parse('$baseUrl/marketplace/products/$encodedId/reviews'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  static Future<dynamic> submitReview(String productId, Map<String, dynamic> reviewData) async {
    try {
      final encodedId = Uri.encodeComponent(productId);
      final response = await http.post(
        Uri.parse('$baseUrl/marketplace/products/$encodedId/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reviewData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      throw Exception('Error submitting review: $e');
    }
  }

  static Future<List<dynamic>> fetchRelatedProducts(String productId) async {
    try {
      final encodedId = Uri.encodeComponent(productId);
      final response = await http.get(Uri.parse('$baseUrl/marketplace/products/$encodedId/related'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load related products');
      }
    } catch (e) {
      throw Exception('Error fetching related products: $e');
    }
  }

  static Future<List<dynamic>> fetchOrders(List<String> cachedPhones) async {
    try {
      String query = '';
      if (cachedPhones.isNotEmpty) {
        final j = cachedPhones.join(',');
        query = '?phones=${Uri.encodeComponent(j)}';
      }
      final response = await http.get(
        Uri.parse('$baseUrl/marketplace/orders/me$query'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  static Future<bool> cancelOrder(String orderId) async {
    try {
      final encodedId = Uri.encodeComponent(orderId);
      final response = await http.delete(
        Uri.parse('$baseUrl/marketplace/orders/$encodedId/cancel'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error canceling order: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> fetchMarketplaceConfig() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/marketplace/config'), headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load marketplace config');
      }
    } catch (e) {
      throw Exception('Error fetching config: $e');
    }
  }
}



