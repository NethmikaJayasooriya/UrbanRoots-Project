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

  final List<Map<String, String>> _soilTypes = [
    {"name": "Potting Mix", "desc": "High Nutrients, Balanced"},
    {"name": "Red Soil", "desc": "Garden Soil, Acidic"},
    {"name": "Sandy / Beach", "desc": "Low Nutrients, Drains Well"},
    {"name": "Compost", "desc": "Organic, High Nitrogen"},
  ];

  final List<String> _wateringOptions = ["Daily", "Every 2 Days", "Weekly"];

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
    const surfaceColor = Color(0xFF1E2220);
    const neonGreen = Color(0xFF00E676);
    
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

              // Question 1: Soil Source (Grid)
              Text(
                "1. Soil Source",
                style: GoogleFonts.poppins(
                  color: neonGreen, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _soilTypes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemBuilder: (context, index) {
                  final type = _soilTypes[index];
                  final isSelected = _selectedSoil == type["name"];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSoil = type["name"]!),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: neonGreen, width: 2)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type["name"]!,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type["desc"]!,
                            style: GoogleFonts.poppins(
                              color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}