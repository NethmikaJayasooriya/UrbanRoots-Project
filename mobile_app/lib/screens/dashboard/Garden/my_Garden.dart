import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'plant_detail_screen.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  String _selectedGarden = "Indoor Garden";
  String? assignedPlantId = "3";

  final List<String> myGardens = ["Indoor Garden", "Home Balcony", "Rooftop"];

  final List<Map<String, dynamic>> plants = [
    {
      "id": "1",
      "name": "Tomato",
      "status": "Healthy",
      "image": "https://images.unsplash.com/photo-1518977676601-b53f02bad6d5?q=80&w=500&auto=format&fit=crop",
      "statusColor": const Color(0xFF00E676),
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
    const bgColor = Color(0xFF07160F);
    const neonGreen = Color(0xFF00E676);
    const surfaceColor = Color(0xFF16201B);

    // ✅ Reserve space for the navbar (65px) + system bottom inset
    final double bottomPadding = 65 + MediaQuery.of(context).padding.bottom;

    return Material(
      color: bgColor,
      child: SafeArea(
        bottom: false, // we handle bottom manually via bottomPadding below
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE (replaces AppBar)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Text(
                  "My Garden",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),

              // GARDEN SWITCHER
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
                          color: isSelected ? neonGreen : surfaceColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            myGardens[index],
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.black : Colors.white38,
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
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38),
              ),
              const SizedBox(height: 15),

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

              const SizedBox(height: 40),
              const Divider(color: Colors.white10),
              const SizedBox(height: 20),
              _buildLargeActionCard(
                "Add New Garden Location",
                "Setup a new indoor space, balcony, or rooftop.",
                Icons.add_home_work_rounded,
                neonGreen,
                surfaceColor,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    bool isAssigned = assignedPlantId == plant['id'];
    const neonGreen = Color(0xFF00E676);
    const surfaceColor = Color(0xFF16201B);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlantDetailScreen(plant: plant)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor, // ✅ FIXED: fallback color so card is visible even if image fails
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isAssigned ? neonGreen : Colors.white10,
            width: isAssigned ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ✅ FIXED: Image.network with error/loading builder so blank cards don't appear
              Image.network(
                plant['image'],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: surfaceColor,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00E676),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: surfaceColor,
                    child: const Center(
                      child: Icon(Icons.yard_rounded, color: Color(0xFF00E676), size: 40),
                    ),
                  );
                },
              ),
              // Dark overlay
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
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAssigned)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Icon(Icons.pets, color: neonGreen, size: 18),
                      ),
                    const Spacer(),
                    Text(
                      plant['name'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
          ),
          Transform.scale(
            scale: 0.65,
            child: Switch(
              value: isAssigned,
              activeColor: const Color(0xFF00E676),
              onChanged: (val) => setState(() => assignedPlantId = id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16201B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Icon(Icons.add_circle_outline, color: Color(0xFF00E676), size: 40),
      ),
    );
  }

  Widget _buildLargeActionCard(
    String title,
    String sub,
    IconData icon,
    Color green,
    Color surface,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: green, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  sub,
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
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