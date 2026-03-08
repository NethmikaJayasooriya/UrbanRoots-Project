import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator. 
static const String baseUrl = 'http://localhost:3000';

  static Future<bool> saveGarden({
    required String userId,
    required String gardenName,
    required String location,
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
        debugPrint('✅ Success: Garden saved to Supabase!');
        return true;
      } else {
        debugPrint('❌ Failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('🚨 Server connection error: $e');
      return false;
    }
  }
}