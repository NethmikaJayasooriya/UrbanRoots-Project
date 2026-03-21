import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
