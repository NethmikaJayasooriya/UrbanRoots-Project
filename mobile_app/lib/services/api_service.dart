// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/api_constants.dart';
import 'package:mobile_app/models/products.dart';
import 'package:mobile_app/models/sale.dart';

// ── Custom exceptions ──────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ── API Service ────────────────────────────────────────────────
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ── Internal helpers ─────────────────────────────────────────

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(ApiConstants.baseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.port,
      path: path,
      queryParameters: query,
    );
  }

  dynamic _parse(http.Response res) {
    final body = utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body.isEmpty ? null : jsonDecode(body);
    }
    String msg = 'Request failed';
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      msg = (json['message'] ?? json['error'] ?? msg).toString();
    } catch (_) {}
    throw ApiException(res.statusCode, msg);
  }

  // ──────────────────────────────────────────────────────────────
  //  PRODUCTS
  // ──────────────────────────────────────────────────────────────

  /// Fetch all products for a seller
  Future<List<Products>> getProducts(String sellerId) async {
    try {
      final res = await _client.get(
        _uri(ApiConstants.products, {'seller_id': sellerId}),
        headers: _headers,
      );
      final data = _parse(res) as List<dynamic>;
      return data
          .map((e) => Products.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  /// Create a new product
  Future<Products> createProduct(Map<String, dynamic> payload) async {
    try {
      final res = await _client.post(
        _uri(ApiConstants.products),
        headers: _headers,
        body: jsonEncode(payload),
      );
      final data = _parse(res) as Map<String, dynamic>;
      return Products.fromJson(data);
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  /// Update product fields
  Future<Products> updateProduct(
      String id, Map<String, dynamic> payload) async {
    try {
      final res = await _client.patch(
        _uri(ApiConstants.productById(id)),
        headers: _headers,
        body: jsonEncode(payload),
      );
      final data = _parse(res) as Map<String, dynamic>;
      return Products.fromJson(data);
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  /// Toggle product active / inactive
  Future<Products> toggleProductActive(String id) async {
    try {
      final res = await _client.patch(
        _uri(ApiConstants.toggleActive(id)),
        headers: _headers,
      );
      final data = _parse(res) as Map<String, dynamic>;
      return Products.fromJson(data);
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      final res = await _client.delete(
        _uri(ApiConstants.productById(id)),
        headers: _headers,
      );
      _parse(res);
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  // ──────────────────────────────────────────────────────────────
  //  SALES
  // ──────────────────────────────────────────────────────────────

  /// Fetch sales for a seller with optional date range
  Future<List<Sale>> getSales(
    String sellerId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final query = <String, String>{'seller_id': sellerId};
      if (from != null) query['from'] = from.toIso8601String();
      if (to != null) query['to'] = to.toIso8601String();

      final res = await _client.get(
        _uri(ApiConstants.sales, query),
        headers: _headers,
      );
      final data = _parse(res) as List<dynamic>;
      return data
          .map((e) => Sale.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }
}
