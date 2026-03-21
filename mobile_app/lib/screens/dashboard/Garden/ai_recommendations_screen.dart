import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/services/api_service.dart';

class AiRecommendationsScreen extends StatefulWidget {
  final Map<String, dynamic> gardenData;

  const AiRecommendationsScreen({super.key, required this.gardenData});

  @override
  State<AiRecommendationsScreen> createState() => _AiRecommendationsScreenState();
}

class _AiRecommendationsScreenState extends State<AiRecommendationsScreen> {
  final Set<String> _addedPlants = {};
  final Set<String> _loadingPlants = {};

  List<Map<String, dynamic>>? aiResults;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    int gardenId = widget.gardenData['garden_id'] ?? 7;
    final results = await ApiService.getAiRecommendations(gardenId);

    if (mounted) {
      if (results != null) {
        setState(() {
          aiResults = List<Map<String, dynamic>>.from(results);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addPlantToGarden(String plantName) async {
    setState(() => _loadingPlants.add(plantName));

    int gardenId = widget.gardenData['garden_id'] ?? 7;
    bool success = await ApiService.addCropToGarden(gardenId, plantName);

    if (mounted) {
      setState(() {
        _loadingPlants.remove(plantName);
        if (success) _addedPlants.add(plantName);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "$plantName added! AI is generating your daily tasks."
                : "Failed to add $plantName. Try again.",
          ),
          backgroundColor: success ? AppColors.primaryGreen : Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getImagePathForPlant(String plantName) {
    final Map<String, String> imagePaths = {
      "bauhinia acuminata": "assets/images/Plants/flowers/Bauhinia_acuminata.jpg",
      "crape jasmine":      "assets/images/Plants/flowers/crape jasmine.webp",
      "hibiscus":           "assets/images/Plants/flowers/hibiscus flower.jpg",
      "night flowering jasmine": "assets/images/Plants/flowers/night flowering jasmine.jpg",
      "rose":               "assets/images/Plants/flowers/rose.jpg",
      "blueberry":          "assets/images/Plants/Fruits/blueberry.webp",
      "cherry":             "assets/images/Plants/Fruits/cherry.jpg",
      "grape":              "assets/images/Plants/Fruits/grape.jpg",
      "orange":             "assets/images/Plants/Fruits/orange.jpg",
      "raspberry":          "assets/images/Plants/Fruits/raspberry.jpg",
      "strawberry":         "assets/images/Plants/Fruits/strawberry.jpg",
      "bell pepper":        "assets/images/Plants/Kitchen Essentials/bell pepper.webp",
      "potato":             "assets/images/Plants/Kitchen Essentials/potato.jpg",
      "soyabean":           "assets/images/Plants/Kitchen Essentials/soyabean.jpg",
      "tomato":             "assets/images/Plants/Kitchen Essentials/tomato.jpg",
    };
    return imagePaths[plantName.toLowerCase()] ?? "assets/images/logo.png";
  }

  // Parses the probability string ("78%") into an int for the progress bar.
  int _parseProbability(String raw) {
    return int.tryParse(raw.replaceAll('%', '').trim()) ?? 0;
  }

  Color _probabilityColor(int pct) {
    if (pct >= 75) return AppColors.primaryGreen;
    if (pct >= 50) return const Color(0xFFFFC107); // amber
    return Colors.redAccent;
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
        // Refresh button in the top-right
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGreen),
              onPressed: _fetchRecommendations,
            ),
        ],
      ),
      body: SafeArea(child: _buildBodyContent()),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "AI Botanist is analyzing\nyour environment...",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      );
    }

    if (_hasError || aiResults == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 52),
              const SizedBox(height: 16),
              Text(
                "Failed to get AI recommendations.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.textMain, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Check your connection and try again.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchRecommendations,
                icon: const Icon(Icons.refresh_rounded, color: Colors.black),
                label: Text(
                  "TRY AGAIN",
                  style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              )
            ],
          ),
        ),
      );
    }

    final int yourPicksCount = aiResults!
        .where((p) => p['is_user_preference'] == true)
        .length;
    final int aiPicksCount = aiResults!.length - yourPicksCount;

    return Column(
      children: [
        // ── Summary header strip ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                _summaryChip(
                  Icons.auto_awesome,
                  "${aiResults!.length}",
                  "Total",
                  Colors.white54,
                ),
                _verticalDivider(),
                _summaryChip(
                  Icons.star_rounded,
                  "$yourPicksCount",
                  "Your Picks",
                  AppColors.primaryGreen,
                ),
                _verticalDivider(),
                _summaryChip(
                  Icons.psychology_outlined,
                  "$aiPicksCount",
                  "AI Picks",
                  const Color(0xFF64B5F6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),

        // ── Cards list ─────────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            itemCount: aiResults!.length,
            itemBuilder: (context, index) =>
                _buildRecommendationCard(aiResults![index]),
          ),
        ),
      ],
    );
  }

  Widget _summaryChip(IconData icon, String count, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                count,
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> plant) {
    final String plantName = plant['plant_name'];
    final String imagePath = _getImagePathForPlant(plantName);
    final bool isUserPick = plant['is_user_preference'] == true;
    final bool isAdded = _addedPlants.contains(plantName);
    final bool isSaving = _loadingPlants.contains(plantName);

    // Parse probability for progress bar
    final String probString = plant['success_probability'] ?? '0%';
    final int probPct = _parseProbability(probString);
    final Color probColor = _probabilityColor(probPct);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          // User's own picks get a green border to stand out
          color: isUserPick
              ? AppColors.primaryGreen.withOpacity(0.4)
              : Colors.white10,
          width: isUserPick ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Plant image + badge row ──────────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.white30, size: 40),
                    ),
                  ),
                ),
              ),

              // Success probability badge (top-right)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: probColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Colors.black, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        probString,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // "Your Pick ⭐" badge (top-left) — only for user-selected plants
              if (isUserPick)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.primaryGreen, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          "Your Pick",
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // ── Card body ────────────────────────────────────────────────────────
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
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  plant['short_reason'] ?? '',
                  style: GoogleFonts.poppins(
                    color: AppColors.textDim,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                // ── Success probability bar ────────────────────────────────────
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      "Success rate",
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 10),
                    ),
                    const Spacer(),
                    Text(
                      probString,
                      style: GoogleFonts.poppins(
                        color: probColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: probPct / 100,
                    minHeight: 5,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(probColor),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Action button ──────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: isAdded
                      ? ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Already planted! Manage it from your Dashboard."),
                                backgroundColor: Colors.orangeAccent,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.black, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "ADDED TO GARDEN",
                                style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      : OutlinedButton(
                          onPressed:
                              isSaving ? null : () => _addPlantToGarden(plantName),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: isSaving
                                    ? Colors.white30
                                    : AppColors.primaryGreen),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: AppColors.primaryGreen,
                                      strokeWidth: 2),
                                )
                              : Text(
                                  "ADD TO GARDEN",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.bold),
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