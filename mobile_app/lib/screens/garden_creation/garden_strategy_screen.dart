import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GardenStrategyScreen extends StatefulWidget {
  const GardenStrategyScreen({super.key});

  @override
  State<GardenStrategyScreen> createState() => _GardenStrategyScreenState();
}

class _GardenStrategyScreenState extends State<GardenStrategyScreen> {
  // State Variables
  String _containerSize = "Medium";
  String _experienceLevel = "Beginner";
  final List<String> _selectedCrops = [];

  // Data Options
  final List<Map<String, dynamic>> _containerOptions = [
    {"name": "Small", "size": "< 6 inches", "icon": Icons.local_florist},
    {"name": "Medium", "size": "10-12 inches", "icon": Icons.grass},
    {"name": "Large", "size": "Ground / Tubs", "icon": Icons.park},
  ];

  final List<String> _cropCategories = [
    "Chillies 🌶️", "Tomatoes 🍅", "Leafy Greens 🥬", 
    "Flowers 🌸", "Herbs 🌿", "Root Veg 🥕", "Fruits 🍓"
  ];

  final List<String> _experienceOptions = ["Beginner", "Intermediate", "Pro"];

  // Helper to toggle crop selection
  void _toggleCrop(String crop) {
    setState(() {
      if (_selectedCrops.contains(crop)) {
        _selectedCrops.remove(crop);
      } else {
        _selectedCrops.add(crop);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
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
              // Header
              Text(
                "Final Details.",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Customize your garden plan based on your space and goals.",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              // 1. Container Size Selection
              Text(
                "1. Container Size",
                style: GoogleFonts.poppins(
                  color: neonGreen, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _containerOptions.map((option) {
                  final isSelected = _containerSize == option["name"];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _containerSize = option["name"]),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: neonGreen, width: 2)
                              : Border.all(color: Colors.transparent),
                        ),
                        child: Column(
                          children: [
                            Icon(option["icon"], 
                                color: isSelected ? neonGreen : Colors.white70, 
                                size: 28),
                            const SizedBox(height: 8),
                            Text(
                              option["name"],
                              style: GoogleFonts.poppins(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              option["size"],
                              style: GoogleFonts.poppins(
                                color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // 2. Crop Selection (Multi-select Chips)
              Text(
                "2. What do you want to grow?",
                style: GoogleFonts.poppins(
                  color: neonGreen, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _cropCategories.map((crop) {
                  final isSelected = _selectedCrops.contains(crop);
                  return FilterChip(
                    label: Text(crop),
                    labelStyle: GoogleFonts.poppins(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    selected: isSelected,
                    selectedColor: neonGreen,
                    backgroundColor: surfaceColor,
                    checkmarkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? neonGreen : surfaceColor),
                    ),
                    onSelected: (_) => _toggleCrop(crop),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // 3. Experience Level
              Text(
                "3. Gardening Experience",
                style: GoogleFonts.poppins(
                  color: neonGreen, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: _experienceOptions.map((level) {
                    final isSelected = _experienceLevel == level;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _experienceLevel = level),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? neonGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              level,
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 40),

              // Final Action Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _selectedCrops.isNotEmpty
                      ? () {
                          // TODO: Navigate to Loading/AI Generation Screen
                          print("Generating garden for: $_containerSize, $_selectedCrops");
                        }
                      : null, // Disable if no crops selected
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    disabledBackgroundColor: surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Analyze & Build Garden 🚀",
                    style: GoogleFonts.poppins(
                      color: _selectedCrops.isNotEmpty ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}