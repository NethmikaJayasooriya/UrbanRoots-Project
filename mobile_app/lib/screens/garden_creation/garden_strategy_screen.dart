import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/services/api_service.dart';

class GardenStrategyScreen extends StatefulWidget {
  final Map<String, dynamic> gardenData;
  // The final callback — fires when the DB save succeeds
  final Function(Map<String, dynamic>)? onGardenCreated;

  const GardenStrategyScreen({
    super.key,
    required this.gardenData,
    this.onGardenCreated,
  });

  @override
  State<GardenStrategyScreen> createState() => _GardenStrategyScreenState();
}

class _GardenStrategyScreenState extends State<GardenStrategyScreen> {
  String _containerSize = "Medium";
  String _experienceLevel = "Beginner";
  String _selectedGoal = "Max Yield";
  final List<String> _selectedCrops = [];

  final List<Map<String, dynamic>> _containerOptions = [
    {"name": "Small", "size": "< 6\"", "icon": Icons.local_florist},
    {"name": "Medium", "size": "10-12\"", "icon": Icons.grass},
    {"name": "Large", "size": "Ground", "icon": Icons.landscape},
  ];

  final List<Map<String, dynamic>> _cropCategories = [
    {"name": "Leafy Greens", "icon": Icons.eco},
    {"name": "Vegetables", "icon": Icons.local_dining},
    {"name": "Yams & Roots", "icon": Icons.grass},
    {"name": "Herbs & Spices", "icon": Icons.local_florist},
    {"name": "Flowers", "icon": Icons.filter_vintage},
    {"name": "Fruits", "icon": Icons.apple},
    {"name": "Medicinal", "icon": Icons.medical_services_outlined},
  ];

  final List<Map<String, dynamic>> _goalOptions = [
    {"name": "Max Yield", "icon": Icons.shopping_bag},
    {"name": "Aesthetic", "icon": Icons.auto_awesome},
    {"name": "Low Care", "icon": Icons.timer},
  ];

  void _toggleCrop(String crop) {
    setState(() {
      _selectedCrops.contains(crop)
          ? _selectedCrops.remove(crop)
          : _selectedCrops.add(crop);
    });
  }

  Future<void> _saveGarden() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving garden to database...'),
        duration: Duration(seconds: 2),
      ),
    );

    bool success = await ApiService.saveGarden(
      userId: widget.gardenData['user_id'] ?? "test_firebase_uid_123",
      gardenName: widget.gardenData['garden_name'] ?? "My Garden",
      location: widget.gardenData['location'] ?? "Unknown",
      latitude: widget.gardenData['latitude'],
      longitude: widget.gardenData['longitude'],
      environment: widget.gardenData['environment'] ?? "Unknown",
      isIotConnected: widget.gardenData['is_iot_connected'] ?? false,
      soilType: widget.gardenData['soil_type'] ?? "Potting Mix",
      sunlightLevel: widget.gardenData['sunlight_level'] ?? 50,
      wateringFrequency: widget.gardenData['watering_frequency'] ?? "Daily",
      isWindy: widget.gardenData['is_windy'] ?? false,
      containerSize: _containerSize,
      gardeningGoal: _selectedGoal,
      targetCrops: _selectedCrops,
      experienceLevel: _experienceLevel,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Garden created successfully!'),
          backgroundColor: AppColors.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );

      // ── KEY: enrich data bundle with strategy choices ──────────────────────
      widget.gardenData['container_size'] = _containerSize;
      widget.gardenData['gardening_goal'] = _selectedGoal;
      widget.gardenData['target_crops'] = _selectedCrops;
      widget.gardenData['experience_level'] = _experienceLevel;

      // ── Notify MyGardenScreen that a garden now exists ─────────────────────
      widget.onGardenCreated?.call(widget.gardenData);

      // ── Pop the entire creation stack back to MainNavigationWrapper ────────
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to create garden. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Strategy.",
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
                letterSpacing: -1,
              ),
            ),
            Text(
              "Refine your setup for optimal growth.",
              style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 14),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("1. Container Size"),
                    const SizedBox(height: 12),
                    Row(
                      children: _containerOptions.map((opt) {
                        bool isSelected = _containerSize == opt["name"];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _containerSize = opt["name"]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryGreen.withOpacity(0.05)
                                    : AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(opt["icon"],
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : Colors.white24,
                                      size: 24),
                                  const SizedBox(height: 8),
                                  Text(
                                    opt["name"],
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? AppColors.textMain
                                          : Colors.white60,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    opt["size"],
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                              .withOpacity(0.7)
                                          : Colors.white24,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    _sectionHeader("2. Target Crops"),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _cropCategories.map((cropData) {
                        String cropName = cropData["name"];
                        IconData cropIcon = cropData["icon"];
                        bool isSelected = _selectedCrops.contains(cropName);
                        return GestureDetector(
                          onTap: () => _toggleCrop(cropName),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primaryGreen, width: 2)
                                  : Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cropIcon,
                                    size: 16,
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white70),
                                const SizedBox(width: 8),
                                Text(
                                  cropName,
                                  style: GoogleFonts.poppins(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    _sectionHeader("3. Gardening Goal"),
                    const SizedBox(height: 12),
                    Row(
                      children: _goalOptions.map((goal) {
                        bool isSelected = _selectedGoal == goal["name"];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _selectedGoal = goal["name"]),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryGreen.withOpacity(0.1)
                                    : AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryGreen
                                        : Colors.transparent),
                              ),
                              child: Column(
                                children: [
                                  Icon(goal["icon"],
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : Colors.white24,
                                      size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    goal["name"],
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? AppColors.textMain
                                          : Colors.white30,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    _sectionHeader("4. Experience Level"),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children:
                            ["Beginner", "Intermediate", "Pro"].map((lvl) {
                          bool isSelected = _experienceLevel == lvl;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _experienceLevel = lvl),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Center(
                                  child: Text(
                                    lvl,
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white30,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _selectedCrops.isEmpty ? null : _saveGarden,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: AppColors.surfaceColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                    "Start Growing",
                    style: GoogleFonts.poppins(
                      color: _selectedCrops.isEmpty
                          ? Colors.white24
                          : Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.poppins(
        color: AppColors.primaryGreen,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    );
  }
}