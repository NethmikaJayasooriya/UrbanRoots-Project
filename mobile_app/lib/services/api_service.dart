import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Used for kIsWeb

class ApiService {
  // Smart URL: Automatically uses localhost for Web, and 10.0.2.2 for Android Emulator
  static String get baseUrl => kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  static Future<bool> saveGarden({
    required String userId,
    required String gardenName,
    required String location,
    
    // 🌍 ADDED: Our new GPS coordinates (nullable in case the user denied GPS permissions)
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
          
          // 🌍 ADDED: Sending the raw numbers straight to NestJS and TypeORM
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

  // 🦇 NEW: Fetches the live weather and digital pet advice for the Bat Cave dashboard
  static Future<Map<String, dynamic>?> getGardenStatus(int gardenId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/gardens/$gardenId/status'));
      
      if (response.statusCode == 200) {
        // Returns the exact JSON bundle we just verified in your browser!
        return jsonDecode(response.body); 
      } else {
        debugPrint('❌ Failed to fetch status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 Server connection error: $e');
      return null;
    }
  }
}