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

class _GardenStrategyScreenState extends State<GardenStrategyScreen>
    with SingleTickerProviderStateMixin {
  String _containerSize = "Medium";
  String _experienceLevel = "Beginner";
  String _selectedGoal = "Max Yield";
  final List<String> _selectedCrops = [];

  // Tracks the active category tab index
  int _activeCategoryIndex = 0;

  late TabController _tabController;

  final List<Map<String, dynamic>> _containerOptions = [
    {"name": "Small", "size": "< 6\"", "icon": Icons.local_florist},
    {"name": "Medium", "size": "10-12\"", "icon": Icons.grass},
    {"name": "Large", "size": "Ground", "icon": Icons.landscape},
  ];

  final List<Map<String, dynamic>> _goalOptions = [
    {"name": "Max Yield", "icon": Icons.shopping_bag},
    {"name": "Aesthetic", "icon": Icons.auto_awesome},
    {"name": "Low Care", "icon": Icons.timer},
  ];

  // ─── CORE FIX ──────────────────────────────────────────────────────────────
  // Plant names exactly match the backend's supportedCrops list so that
  // target_crops in the AI prompt contains precise, actionable plant names
  // instead of vague category labels that the AI cannot map to anything.
  // ───────────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _plantCategories = [
    {
      "category": "Flowers",
      "emoji": "🌸",
      "color": const Color(0xFFFF6B9D),
      "plants": [
        {"name": "crape jasmine",           "icon": Icons.local_florist},
        {"name": "Bauhinia acuminata",       "icon": Icons.filter_vintage},
        {"name": "Hibiscus",                 "icon": Icons.spa},
        {"name": "night flowering jasmine",  "icon": Icons.nights_stay_outlined},
        {"name": "rose",                     "icon": Icons.favorite_border},
      ],
    },
    {
      "category": "Fruits",
      "emoji": "🍓",
      "color": const Color(0xFFFF8C42),
      "plants": [
        {"name": "blueberry",   "icon": Icons.circle},
        {"name": "cherry",      "icon": Icons.favorite},
        {"name": "grape",       "icon": Icons.bubble_chart},
        {"name": "strawberry",  "icon": Icons.star_border},
        {"name": "raspberry",   "icon": Icons.grain},
        {"name": "orange",      "icon": Icons.brightness_5_outlined},
      ],
    },
    {
      "category": "Kitchen",
      "emoji": "🥦",
      "color": const Color(0xFF4CAF50),
      "plants": [
        {"name": "bell pepper", "icon": Icons.eco},
        {"name": "tomato",      "icon": Icons.circle_outlined},
        {"name": "soyabean",    "icon": Icons.grass},
        {"name": "potato",      "icon": Icons.fiber_manual_record},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _plantCategories.length,
      vsync: this,
    )..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() => _activeCategoryIndex = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleCrop(String crop) {
    setState(() {
      _selectedCrops.contains(crop)
          ? _selectedCrops.remove(crop)
          : _selectedCrops.add(crop);
    });
  }

  // Selects / deselects all plants in the active category
  void _toggleSelectAll(List<dynamic> plants) {
    final names = plants.map((p) => p["name"] as String).toList();
    final allSelected = names.every((n) => _selectedCrops.contains(n));
    setState(() {
      if (allSelected) {
        _selectedCrops.removeWhere((c) => names.contains(c));
      } else {
        for (final n in names) {
          if (!_selectedCrops.contains(n)) _selectedCrops.add(n);
        }
      }
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
                    // ── Section 1: Container Size ────────────────────────────
                    _sectionHeader("1. Container Size"),
                    const SizedBox(height: 12),
                    Row(
                      children: _containerOptions.map((opt) {
                        bool isSelected = _containerSize == opt["name"];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _containerSize = opt["name"]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 16),
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

                    // ── Section 2: Target Crops (UPGRADED) ──────────────────
                    _buildTargetCropsSection(),
                    const SizedBox(height: 28),

                    // ── Section 3: Gardening Goal ────────────────────────────
                    _sectionHeader("3. Gardening Goal"),
                    const SizedBox(height: 12),
                    Row(
                      children: _goalOptions.map((goal) {
                        bool isSelected = _selectedGoal == goal["name"];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedGoal = goal["name"]),
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

                    // ── Section 4: Experience Level ──────────────────────────
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

  // ─── UPGRADED TARGET CROPS SECTION ─────────────────────────────────────────
  Widget _buildTargetCropsSection() {
    final categoryData = _plantCategories[_activeCategoryIndex];
    final List<dynamic> plants = categoryData["plants"];
    final Color accentColor = categoryData["color"];
    final allSelected = plants.every(
      (p) => _selectedCrops.contains(p["name"] as String),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: label + selection count badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionHeader("2. Target Crops"),
            if (_selectedCrops.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_selectedCrops.length} selected",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Pick the specific plants you want to grow. This directly guides the AI.",
          style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 11),
        ),
        const SizedBox(height: 14),

        // Category tab pills
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _plantCategories.length,
            itemBuilder: (context, index) {
              final cat = _plantCategories[index];
              final isActive = _activeCategoryIndex == index;

              // Count selected in this category
              final List<dynamic> catPlants = cat["plants"];
              final int selectedCount = catPlants
                  .where((p) => _selectedCrops.contains(p["name"] as String))
                  .length;

              return GestureDetector(
                onTap: () {
                  setState(() => _activeCategoryIndex = index);
                  _tabController.animateTo(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (cat["color"] as Color).withOpacity(0.15)
                        : AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? (cat["color"] as Color)
                          : Colors.white10,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        cat["emoji"],
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat["category"],
                        style: GoogleFonts.poppins(
                          color: isActive
                              ? (cat["color"] as Color)
                              : Colors.white38,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      if (selectedCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: cat["color"] as Color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "$selectedCount",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // Plant cards panel
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Container(
            key: ValueKey(_activeCategoryIndex),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Select All" row
                GestureDetector(
                  onTap: () => _toggleSelectAll(plants),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                          color: allSelected
                              ? accentColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: allSelected ? accentColor : Colors.white30,
                            width: 1.5,
                          ),
                        ),
                        child: allSelected
                            ? const Icon(Icons.check,
                                size: 11, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        allSelected ? "Deselect all" : "Select all",
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 12),

                // Plant chips grid
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: plants.map((plantData) {
                    final String plantName = plantData["name"];
                    final IconData icon = plantData["icon"];
                    final bool isSelected = _selectedCrops.contains(plantName);

                    return GestureDetector(
                      onTap: () => _toggleCrop(plantName),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentColor.withOpacity(0.18)
                              : AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? accentColor : Colors.white12,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : icon,
                              size: 14,
                              color: isSelected ? accentColor : Colors.white38,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              // Capitalise first letter for display
                              _toDisplayName(plantName),
                              style: GoogleFonts.poppins(
                                color: isSelected ? accentColor : Colors.white60,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        // Mini preview of all selected plants across all categories
        if (_selectedCrops.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.primaryGreen, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      "AI will prioritise these for you",
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: _selectedCrops.map((name) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _toDisplayName(name),
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Capitalise the first letter of each word for display only.
  // The original lowercase name is what's stored/sent to the backend.
  String _toDisplayName(String name) {
    return name
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
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