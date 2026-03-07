import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'plant_detail_screen.dart';
import 'package:mobile_app/core/theme/app_colors.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  String _selectedGarden = "Indoor Garden";
  String? assignedPlantId = "3";

  // Garden categories
  final List<String> myGardens = const ["Indoor Garden", "Home Balcony", "Rooftop"];

  // Static plant data for SDGP prototype
  final List<Map<String, dynamic>> plants = [
    {
      "id": "1",
      "name": "Tomato",
      "status": "Healthy",
      "image": "https://images.unsplash.com/photo-1518977676601-b53f02bad6d5?q=80&w=500&auto=format&fit=crop",
      "statusColor": AppColors.primaryGreen,
    },
    {
      "id": "2",
      "name": "Lettuce",
      "status": "Check Needed",
      "image": "https://images.unsplash.com/photo-1622206141540-5844544d3db5?q=80&w=500&auto=format&fit=crop",
      "statusColor": Colors.orangeAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Calculates safe padding so the bottom nav bar doesn't cover content
    final double bottomPadding = 24 + MediaQuery.of(context).padding.bottom;

    return Material(
      color: AppColors.backgroundColor,
      child: SafeArea(
        bottom: false, 
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Title
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Text(
                  "My Garden",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                    fontSize: 24,
                  ),
                ),
              ),

              // Horizontal Garden Location Switcher
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: myGardens.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedGarden == myGardens[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGarden = myGardens[index]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryGreen : AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            myGardens[index],
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

              // The grid displaying user's plants
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

              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              
              // Action card to create a brand new location
              _buildLargeActionCard(
                "Add New Garden Location",
                "Setup a new indoor space, balcony, or rooftop.",
                Icons.add_home_work_rounded,
              ),
              
              // Extra space to ensure the card isn't clipped by the notch
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
    );
  }

  // Generates individual plant cards with image loading fallbacks
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
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                        strokeWidth: 2,
                      ),
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
              // Gradient for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
                ),
              ),
              // Card textual content
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
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                        fontSize: 18,
                      ),
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

  // Small toggle to link the plant to the user's digital pet
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
          Text(
            "Link Pet",
            style: GoogleFonts.poppins(color: AppColors.textMain, fontSize: 10),
          ),
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

  // Card UI for adding a new crop to the grid
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

  // Card UI for creating a completely new garden (e.g., Rooftop)
  Widget _buildLargeActionCard(String title, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  sub,
                  style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        ],
      ),
    );
  }
}