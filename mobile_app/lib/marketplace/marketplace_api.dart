import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MarketplaceApi {
  static final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

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
        headers: {'Content-Type': 'application/json'},
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
}


