import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GardenStrategyScreen extends StatefulWidget {
  const GardenStrategyScreen({super.key});

  @override
  State<GardenStrategyScreen> createState() => _GardenStrategyScreenState();
}

class _GardenStrategyScreenState extends State<GardenStrategyScreen> {
  String _containerSize = "Medium";
  String _experienceLevel = "Beginner";
  String _selectedGoal = "Maximum Yield";
  final List<String> _selectedCrops = [];

  final List<Map<String, dynamic>> _containerOptions = [
    {"name": "Small", "size": "< 6\"", "icon": Icons.local_florist},
    {"name": "Medium", "size": "10-12\"", "icon": Icons.grass},
    {"name": "Large", "size": "Ground", "icon": Icons.landscape},
  ];

  final List<String> _cropCategories = [
    "Leafy Greens 🥬", "Vegetables 🍅", "Yams & Roots 🥕",
    "Herbs & Spices 🌿", "Flowers 🌸", "Fruits 🍓", "Medicinal Plants 💊",
  ];

  final List<Map<String, dynamic>> _goalOptions = [
    {"name": "Maximum Yield", "icon": Icons.shopping_bag},
    {"name": "Aesthetic", "icon": Icons.auto_awesome},
    {"name": "Low Care", "icon": Icons.timer},
  ];

  void _toggleCrop(String crop) {
    setState(() {
      _selectedCrops.contains(crop) ? _selectedCrops.remove(crop) : _selectedCrops.add(crop);
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF07160F);
    const surfaceColor = Color(0xFF16201B);
    const accentGreen = Color(0xFF00E676);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Strategy.", style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
            Text("Refine your setup for optimal growth.", style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("1. Container Size", accentGreen),
                    const SizedBox(height: 12),
                    Row(
                      children: _containerOptions.map((opt) {
                        bool isSelected = _containerSize == opt["name"];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _containerSize = opt["name"]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? accentGreen.withOpacity(0.05) : surfaceColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? accentGreen : Colors.transparent, width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  Icon(opt["icon"], color: isSelected ? accentGreen : Colors.white24, size: 24),
                                  const SizedBox(height: 8),
                                  Text(opt["name"], style: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(opt["size"], style: GoogleFonts.poppins(color: isSelected ? accentGreen.withOpacity(0.7) : Colors.white24, fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    _sectionHeader("2. Target Crops", accentGreen),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 10,
                      children: _cropCategories.map((crop) {
                        bool isSelected = _selectedCrops.contains(crop);
                        return GestureDetector(
                          onTap: () => _toggleCrop(crop),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), 
                            decoration: BoxDecoration(color: isSelected ? accentGreen : surfaceColor, borderRadius: BorderRadius.circular(12)),
                            child: Text(crop, style: GoogleFonts.poppins(color: isSelected ? Colors.black : Colors.white70, fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    _sectionHeader("3. Gardening Goal", accentGreen),
                    const SizedBox(height: 12),
                    Row(
                      children: _goalOptions.map((goal) {
                        bool isSelected = _selectedGoal == goal["name"];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedGoal = goal["name"]),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? accentGreen.withOpacity(0.1) : surfaceColor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: isSelected ? accentGreen : Colors.transparent),
                              ),
                              child: Column(
                                children: [
                                  Icon(goal["icon"], color: isSelected ? accentGreen : Colors.white24, size: 20),
                                  const SizedBox(height: 4),
                                  Text(goal["name"], style: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    _sectionHeader("4. Experience Level", accentGreen),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        children: ["Beginner", "Intermediate", "Pro"].map((lvl) {
                          bool isSelected = _experienceLevel == lvl;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _experienceLevel = lvl),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(color: isSelected ? accentGreen : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                                child: Center(
                                  child: Text(lvl, style: GoogleFonts.poppins(color: isSelected ? Colors.black : Colors.white30, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 10),
              child: SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  onPressed: _selectedCrops.isEmpty ? null : () {
                    // Navigate to Analysis / Loading
                    print("Generating for: $_containerSize, $_selectedGoal, $_selectedCrops");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen, disabledBackgroundColor: surfaceColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text("Analyze & Build Garden ✨", style: GoogleFonts.poppins(color: _selectedCrops.isEmpty ? Colors.white24 : Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Text(title.toUpperCase(), style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.2));
  }
}