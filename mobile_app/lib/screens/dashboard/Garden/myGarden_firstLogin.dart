import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'plant_detail_screen.dart';
import 'ai_recommendations_screen.dart'; // Make sure you have this file created
import 'package:mobile_app/core/theme/app_colors.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  // Simulates data fetched from the backend after user registration
  final List<Map<String, dynamic>> userGardens = [
    {"id": "1", "name": "Main Garden"} 
  ];

  String? _selectedGardenId;
  String? assignedPlantId;

  final List<Map<String, dynamic>> plants = []; 

  @override
  void initState() {
    super.initState();
    if (userGardens.isNotEmpty) {
      _selectedGardenId = userGardens[0]['id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = 24 + MediaQuery.of(context).padding.bottom;

    // Dynamically fetch the name of the currently selected garden
    String dynamicTitle = userGardens.isNotEmpty 
        ? userGardens.firstWhere((g) => g['id'] == _selectedGardenId, orElse: () => {"name": "My Garden"})['name']
        : "My Garden";

    return Material(
      color: AppColors.backgroundColor,
      child: SafeArea(
        bottom: false, 
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Text(
                  dynamicTitle,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                    fontSize: 24,
                  ),
                ),
              ),

              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: userGardens.length,
                  itemBuilder: (context, index) {
                    final garden = userGardens[index];
                    bool isSelected = _selectedGardenId == garden['id'];
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGardenId = garden['id']),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryGreen : AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            garden['name'], 
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.black : AppColors.textDim,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              
              Text(
                "Active Crops",
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDim),
              ),
              const SizedBox(height: 15),

              if (plants.isEmpty)
                _buildAiRecommendationPromo()
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: plants.length + 1,
                  itemBuilder: (context, index) {
                    if (index == plants.length) return _buildAddCard();
                    return _buildPlantCard(plants[index]);
                  },
                ),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiRecommendationPromo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: AppColors.primaryGreen, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            "Your Garden is Ready!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Let our AI analyze your saved environment details to recommend the perfect crops for your space.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textDim,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48, 
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AiRecommendationsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                "GET RECOMMENDATION",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    bool isAssigned = assignedPlantId == plant['id'];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlantDetailScreen(plant: plant)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isAssigned ? AppColors.primaryGreen : Colors.white10,
            width: isAssigned ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                plant['image'],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.surfaceColor,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceColor,
                    child: const Center(
                      child: Icon(Icons.yard_rounded, color: AppColors.primaryGreen, size: 40),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAssigned)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Icon(Icons.pets, color: AppColors.primaryGreen, size: 18),
                      ),
                    const Spacer(),
                    Text(
                      plant['name'],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 18),
                    ),
                    Text(
                      plant['status'],
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    _buildLinkToggle(plant['id'], isAssigned),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkToggle(String id, bool isAssigned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Link Pet", style: GoogleFonts.poppins(color: AppColors.textMain, fontSize: 10)),
          Transform.scale(
            scale: 0.65,
            child: Switch(
              value: isAssigned,
              activeColor: AppColors.primaryGreen,
              onChanged: (val) => setState(() => assignedPlantId = val ? id : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Icon(Icons.add_circle_outline, color: AppColors.primaryGreen, size: 40),
      ),
    );
  }
}