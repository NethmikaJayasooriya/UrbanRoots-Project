import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/app_colors.dart';

class AiRecommendationsScreen extends StatefulWidget {
  // Receives garden context so AI can tailor results
  final Map<String, dynamic> gardenData;

  const AiRecommendationsScreen({super.key, required this.gardenData});

  @override
  State<AiRecommendationsScreen> createState() => _AiRecommendationsScreenState();
}

class _AiRecommendationsScreenState extends State<AiRecommendationsScreen> {
  // Tracks which plants the user has selected
  final Set<String> _addedPlants = {};

  // ── Hardcoded AI results (swap with real API call later) ──────────────────
  final List<Map<String, dynamic>> aiResults = [
    {
      "plant_name": "tomato",
      "success_probability": "92%",
      "short_reason":
          "Tomatoes thrive in warm temperatures, and your current soil type is a perfect match for root growth.",
    },
    {
      "plant_name": "bell pepper",
      "success_probability": "85%",
      "short_reason":
          "High humidity is ideal for bell peppers, though they will need steady sunlight.",
    },
    {
      "plant_name": "Bauhinia acuminata",
      "success_probability": "78%",
      "short_reason":
          "This tropical shrub fits your indoor environment well but requires careful moisture management.",
    },
  ];

  // ── Maps plant name → local asset image path ──────────────────────────────
  String _getImagePathForPlant(String plantName) {
    final Map<String, String> imagePaths = {
      "bauhinia acuminata": "assets/images/Plants/flowers/Bauhinia_acuminata.jpg",
      "crape jasmine": "assets/images/Plants/flowers/crape jasmine.webp",
      "hibiscus": "assets/images/Plants/flowers/hibiscus flower.jpg",
      "night flowering jasmine": "assets/images/Plants/flowers/night flowering jasmine.jpg",
      "rose": "assets/images/Plants/flowers/rose.jpg",
      "blueberry": "assets/images/Plants/Fruits/blueberry.webp",
      "cherry": "assets/images/Plants/Fruits/cherry.jpg",
      "grape": "assets/images/Plants/Fruits/grape.jpg",
      "orange": "assets/images/Plants/Fruits/orange.jpg",
      "raspberry": "assets/images/Plants/Fruits/raspberry.jpg",
      "strawberry": "assets/images/Plants/Fruits/strawberry.jpg",
      "bell pepper": "assets/images/Plants/Kitchen Essentials/bell pepper.webp",
      "potato": "assets/images/Plants/Kitchen Essentials/potato.jpg",
      "soyabean": "assets/images/Plants/Kitchen Essentials/soyabean.jpg",
      "tomato": "assets/images/Plants/Kitchen Essentials/tomato.jpg",
    };
    return imagePaths[plantName.toLowerCase()] ?? "assets/images/logo.png";
  }

  // ── Converts selected plant names → full plant maps for MyGardenScreen ───
  List<Map<String, dynamic>> _buildSelectedPlantMaps() {
    return _addedPlants.map((plantName) {
      return {
        'id': plantName.replaceAll(' ', '_').toLowerCase(),
        'name': _capitalize(plantName),
        'image': _getImagePathForPlant(plantName),
        'imageIsAsset': true, // tells MyGardenScreen to use Image.asset
        'status': 'Freshly added · Thriving',
        'moisture': '—',
        'sunlight': '—',
      };
    }).toList();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  // ── Confirm and return to MyGardenScreen ─────────────────────────────────
  void _confirmSelection() {
    final plants = _buildSelectedPlantMaps();
    Navigator.pop(context, plants);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "AI Results",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Recommendation cards list ───────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                itemCount: aiResults.length,
                itemBuilder: (context, index) {
                  return _buildRecommendationCard(aiResults[index]);
                },
              ),
            ),

            // ── Sticky "Create Your Garden" button at the bottom ───────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_addedPlants.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "${_addedPlants.length} crop${_addedPlants.length > 1 ? 's' : ''} selected",
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _addedPlants.isEmpty ? null : _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        disabledBackgroundColor: AppColors.surfaceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.yard_rounded,
                            color: _addedPlants.isEmpty ? Colors.white24 : Colors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "CREATE YOUR GARDEN",
                            style: GoogleFonts.poppins(
                              color: _addedPlants.isEmpty ? Colors.white24 : Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> plant) {
    final String plantName = plant['plant_name'];
    final String imagePath = _getImagePathForPlant(plantName);
    final bool isAdded = _addedPlants.contains(plantName);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdded ? AppColors.primaryGreen.withOpacity(0.5) : Colors.white10,
          width: isAdded ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + success badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 140,
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.white30, size: 40),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.black, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        plant['success_probability'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Text + add/remove button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plantName.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plant['short_reason'],
                  style: GoogleFonts.poppins(
                    color: AppColors.textDim,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle add / remove
                SizedBox(
                  width: double.infinity,
                  child: isAdded
                      ? ElevatedButton(
                          onPressed: () {
                            setState(() => _addedPlants.remove(plantName));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("$plantName removed."),
                                backgroundColor: Colors.redAccent,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.black, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "ADDED TO GARDEN",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : OutlinedButton(
                          onPressed: () {
                            setState(() => _addedPlants.add(plantName));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("$plantName added!"),
                                backgroundColor: AppColors.primaryGreen,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "ADD TO GARDEN",
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}