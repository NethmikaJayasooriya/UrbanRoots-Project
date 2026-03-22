import 'package:mobile_app/models/seller.dart';
import 'package:mobile_app/models/sale.dart';
import 'package:mobile_app/models/products.dart';
import 'package:mobile_app/core/api_constants.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String baseUrl = kIsWeb ? 'http://127.0.0.1:3000' : 'http://192.168.1.5:3000';

  static Future<int?> getStoredGardenId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('active_garden_id');
  }

  static Future<bool> saveGarden({
    required String userId,
    required String gardenName,
    required String location,
    required double? latitude,
    required double? longitude,
    required String environment,
    required bool isIotConnected,
    required String soilType,
    required int sunlightLevel,
    required String wateringFrequency,
    required bool isWindy,
    required String containerSize,
    required String gardeningGoal,
    required List<String> targetCrops,
    required String experienceLevel,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gardens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'garden_name': gardenName,
          'location': location,
          'latitude': latitude,
          'longitude': longitude,
          'environment': environment,
          'is_iot_connected': isIotConnected,
          'soil_type': soilType,
          'sunlight_level': sunlightLevel,
          'watering_frequency': wateringFrequency,
          'is_windy': isWindy,
          'container_size': containerSize,
          'gardening_goal': gardeningGoal,
          'target_crops': targetCrops,
          'experience_level': experienceLevel,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['garden_id'] != null) {
           final prefs = await SharedPreferences.getInstance();
           await prefs.setInt('active_garden_id', data['data']['garden_id']);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<int?> fetchUserGardenId(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/gardens/user/$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data']['garden_id'] as int?; 
        }
      }
    } catch (e) {
      debugPrint('Error fetching user garden: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getGardenStatus([int? gardenId]) async {
    final id = gardenId ?? await getStoredGardenId();
    if (id == null) return null;

    try {
      final response = await http.get(Uri.parse('$baseUrl/gardens/$id/status'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      }
    } catch (e) {
      debugPrint('Error fetching status: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> getAiRecommendations(int gardenId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/gardens/$gardenId/recommendations'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['recommendations'];
      }
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
    }
    return null;
  }

  static Future<bool> addCropToGarden(int gardenId, String plantName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gardens/$gardenId/crops'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'plant_name': plantName}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>?> getGardenCrops(int gardenId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/gardens/$gardenId/crops'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching crops: $e');
    }
    return null;
  }

  static Future<bool> linkPetToPlant(int gardenId, int cropId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/gardens/$gardenId/link-pet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'crop_id': cropId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // NEW METHOD: Saves the task checklist progress to the database
  static Future<bool> updateCropTasks(int gardenId, int cropId, List<dynamic> tasks) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/gardens/$gardenId/crops/$cropId/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tasks': tasks}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating tasks: $e');
      return false;
    }
  }

  /// Sends an IoT sensor alert to the backend for plant-specific AI dialogue.
  /// Returns { pet_dialogue, care_action } or null on failure.
  static Future<Map<String, dynamic>?> postIoTAlert(
    int gardenId,
    Map<String, dynamic> alertData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gardens/$gardenId/iot-alert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(alertData),
      ).timeout(const Duration(seconds: 8)); // Short timeout — pet dialogue should be fast
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data;
      }
    } catch (e) {
      debugPrint('IoT alert post failed: $e');
    }
    return null;
  }

  static Future<String?> fetchDiseaseTreatment(String diseaseName) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/disease/treatment?name=$diseaseName')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['treatment'];
      }
    } catch (e) {
      debugPrint('Error fetching treatment: $e');
    }
    return null;
  }


  // --- INJECTED SELLER API METHODS ---
static final _client = http.Client();

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-user-id': FirebaseAuth.instance.currentUser?.uid ?? '',
      };

  // ÔöÇÔöÇ Internal helpers ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ

  static Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(ApiConstants.baseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.port,
      path: path,
      queryParameters: query,
    );
  }

  static dynamic _parse(http.Response res) {
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

  // ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  //  SELLERS
  // ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ

  /// Get seller by their auth uid ÔÇö returns null if not found (404)
  /// Used on app startup to decide which screen to show
  static Future<Seller?> getSellerByUid(String uid) async {
    try {
      final res = await _client.get(
        _uri(ApiConstants.sellerByUid(uid)),
        headers: _headers,
      );
      if (res.statusCode == 404) return null;
      final data = _parse(res) as Map<String, dynamic>;
      return Seller.fromJson(data);
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  /// Get seller by their seller UUID
  static Future<Seller> getSellerById(String id) async {
    try {
      final res = await _client.get(
        _uri(ApiConstants.sellerById(id)),
        headers: _headers,
      );
      final data = _parse(res) as Map<String, dynamic>;
      return Seller.fromJson(data);
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  /// Create a new seller during onboarding
  static Future<Seller> createSeller(Map<String, dynamic> payload) async {
    try {
      final res = await _client.post(
        _uri(ApiConstants.sellers),
        headers: _headers,
        body: jsonEncode(payload),
      );
      final data = _parse(res) as Map<String, dynamic>;
      return Seller.fromJson(data);
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  /// Update seller profile and payment details
  static Future<Seller> updateSeller(
      String id, Map<String, dynamic> payload) async {
    try {
      final res = await _client.patch(
        _uri(ApiConstants.sellerById(id)),
        headers: _headers,
        body: jsonEncode(payload),
      );
      final data = _parse(res) as Map<String, dynamic>;
      return Seller.fromJson(data);
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  // ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  //  PRODUCTS
  // ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ

  /// Upload a raw product image file and return the generated remote URL
  static Future<String> uploadProductImage(PlatformFile file) async {
    try {
      final uri = _uri('/products/upload');
      final request = http.MultipartRequest('POST', uri);
      
      if (file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image', file.bytes!, filename: file.name,
        ));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image', file.path!,
        ));
      } else {
        throw const ApiException(0, 'Invalid file pick');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _parse(response) as Map<String, dynamic>;
      return data['imageUrl'] as String;
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  static Future<List<Products>> getProducts(String sellerId) async {
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

  static Future<Products> createProduct(Map<String, dynamic> payload) async {
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

  static Future<Products> updateProduct(
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

  static Future<Products> toggleProductActive(String id) async {
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

  static Future<void> deleteProduct(String id) async {
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

  // ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  //  SALES
  // ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ

  static Future<List<Sale>> getSales(
    String sellerId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final query = <String, String>{'seller_id': sellerId};
      if (from != null) query['from'] = from.toIso8601String();
      if (to != null)   query['to']   = to.toIso8601String();

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

  // ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  //  BENEFICIARIES
  // ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ

  static Future<List<Map<String, dynamic>>> getBeneficiaries(
      String sellerId) async {
    try {
      final res = await _client.get(
        _uri(ApiConstants.beneficiaries, {'seller_id': sellerId}),
        headers: _headers,
      );
      final data = _parse(res) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  static Future<Map<String, dynamic>> createBeneficiary(
      Map<String, dynamic> payload) async {
    try {
      final res = await _client.post(
        _uri(ApiConstants.beneficiaries),
        headers: _headers,
        body: jsonEncode(payload),
      );
      return _parse(res) as Map<String, dynamic>;
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

  static Future<void> deleteBeneficiary(String id) async {
    try {
      final res = await _client.delete(
        _uri(ApiConstants.beneficiaryById(id)),
        headers: _headers,
      );
      _parse(res);
    } on SocketException {
      throw const ApiException(0, 'No internet connection');
    }
  }

}

// --- INJECTED EXCEPTIONS ---
class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ÔöÇÔöÇ API Service ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
