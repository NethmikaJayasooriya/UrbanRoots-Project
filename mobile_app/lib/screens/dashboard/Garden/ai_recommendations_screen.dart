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
  // State tracking
  final Set<String> _addedPlants = {};
  final Set<String> _loadingPlants = {}; // Tracks which plant is currently saving
  
  List<Map<String, dynamic>>? aiResults;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  // Calls the NestJS backend to ask Gemini for crops
  Future<void> _fetchRecommendations() async {
    // Note: Defaulting to garden ID 7 for testing if not provided in gardenData
    int gardenId = widget.gardenData['garden_id'] ?? 7; 
    
    final results = await ApiService.getAiRecommendations(gardenId);
    
    if (mounted) {
      if (results != null) {
        setState(() {
          // Convert dynamic list to strongly typed map
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

  // Calls the NestJS backend to save the crop and generate daily tasks
  Future<void> _addPlantToGarden(String plantName) async {
    setState(() => _loadingPlants.add(plantName));

    int gardenId = widget.gardenData['garden_id'] ?? 7;
    bool success = await ApiService.addCropToGarden(gardenId, plantName);

    if (mounted) {
      setState(() {
        _loadingPlants.remove(plantName);
        if (success) {
          _addedPlants.add(plantName);
        }
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
      // Flowers
      "bauhinia acuminata": "assets/images/Plants/flowers/Bauhinia_acuminata.jpg",
      "crape jasmine": "assets/images/Plants/flowers/crape jasmine.webp",
      "hibiscus": "assets/images/Plants/flowers/hibiscus flower.jpg",
      "night flowering jasmine": "assets/images/Plants/flowers/night flowering jasmine.jpg",
      "rose": "assets/images/Plants/flowers/rose.jpg",
      
      // Fruits
      "blueberry": "assets/images/Plants/Fruits/blueberry.webp",
      "cherry": "assets/images/Plants/Fruits/cherry.jpg",
      "grape": "assets/images/Plants/Fruits/grape.jpg",
      "orange": "assets/images/Plants/Fruits/orange.jpg",
      "raspberry": "assets/images/Plants/Fruits/raspberry.jpg",
      "strawberry": "assets/images/Plants/Fruits/strawberry.jpg",
      
      // Kitchen Essentials
      "bell pepper": "assets/images/Plants/Kitchen Essentials/bell pepper.webp",
      "potato": "assets/images/Plants/Kitchen Essentials/potato.jpg",
      "soyabean": "assets/images/Plants/Kitchen Essentials/soyabean.jpg",
      "tomato": "assets/images/Plants/Kitchen Essentials/tomato.jpg",
    };

    return imagePaths[plantName.toLowerCase()] ?? "assets/images/logo.png"; 
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
        child: _buildBodyContent(),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryGreen),
            const SizedBox(height: 20),
            Text(
              "AI Botanist is analyzing your environment...",
              style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_hasError || aiResults == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              "Failed to get AI recommendations.",
              style: GoogleFonts.poppins(color: AppColors.textMain, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _fetchRecommendations();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              child: Text(
                "TRY AGAIN",
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: aiResults!.length,
      itemBuilder: (context, index) {
        return _buildRecommendationCard(aiResults![index]);
      },
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> plant) {
    final String plantName = plant['plant_name'];
    final String imagePath = _getImagePathForPlant(plantName);
    
    final bool isAdded = _addedPlants.contains(plantName);
    final bool isSaving = _loadingPlants.contains(plantName);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white30, size: 40)),
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
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
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
                  style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: isAdded
                      // STATE: WHEN ALREADY ADDED TO DATABASE
                      ? ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Already planted! Manage it from your Dashboard."),
                                backgroundColor: Colors.orangeAccent,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.black, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "ADDED TO GARDEN",
                                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      // STATE: DEFAULT OR LOADING
                      : OutlinedButton(
                          onPressed: isSaving ? null : () => _addPlantToGarden(plantName),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isSaving ? Colors.white30 : AppColors.primaryGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSaving 
                            ? const SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2)
                              )
                            : Text(
                                "ADD TO GARDEN",
                                style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
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