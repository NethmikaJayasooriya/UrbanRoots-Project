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
  bool _isWindy = false;

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

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF121413);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Describe your\nEnvironment.",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Since you don't have a sensor, we need a few more details to calibrate the AI.",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}