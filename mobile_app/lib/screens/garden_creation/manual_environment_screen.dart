import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManualEnvironmentScreen extends StatefulWidget {
  const ManualEnvironmentScreen({super.key});

  @override
  State<ManualEnvironmentScreen> createState() => _ManualEnvironmentScreenState();
}

class _ManualEnvironmentScreenState extends State<ManualEnvironmentScreen> {
  // State variables
  String _selectedSoil = "Potting Mix";
  double _sunlightValue = 50; 
  String _wateringFrequency = "Daily";
  bool _isWindy = false; //variable for high rise balconies

  // Soil Options Data
  final List<Map<String, String>> _soilTypes = [
    {"name": "Potting Mix", "desc": "High Nutrients, Balanced"},
    {"name": "Red Soil", "desc": "Garden Soil, Acidic"},
    {"name": "Sandy / Beach", "desc": "Low Nutrients, Drains Well"},
    {"name": "Compost", "desc": "Organic, High Nitrogen"},
  ];

  // Watering Options
  final List<String> _wateringOptions = ["Daily", "Every 2 Days", "Weekly"];

  // Helper to get sunlight info
  Map<String, dynamic> _getSunlightInfo() {
    if (_sunlightValue < 30) {
      return {"label": "Shadow / Low Light", "icon": Icons.cloud};
    } else if (_sunlightValue < 70) {
      return {"label": "Partial Sun", "icon": Icons.wb_cloudy};
    } else {
      return {"label": "Direct Sunlight", "icon": Icons.wb_sunny};
    }
  }
}