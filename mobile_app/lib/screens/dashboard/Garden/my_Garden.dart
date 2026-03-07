import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  // Track which plant ID is currently linked to the digital pet
  String? assignedPlantId = "1"; 

  void _handleToggle(String plantId) {
    setState(() {
      // If clicking the already assigned one, it stays assigned (logic for 1-to-1)
      // Otherwise, switch the assignment to the new plant
      assignedPlantId = plantId;
    });
    // TODO: Update Firestore with the new assignedPlantId for this user
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF07160F);
    const neonGreen = Color(0xFF00E676);
    const cardColor = Color(0xFF16201B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("My Garden", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manage Your Crops",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54)),
            const SizedBox(height: 25),
            
            // Plant Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.75, // Adjusted to fit the toggle
              children: [
                _buildPlantCard("1", "Tomato", "Healthy", neonGreen, cardColor),
                _buildPlantCard("2", "Lettuce", "Thirsty", Colors.orangeAccent, cardColor),
                _buildPlantCard("3", "Spinach", "Healthy", neonGreen, cardColor),
                // Add Plant Placeholder
                _buildAddCard(cardColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard(String id, String name, String status, Color statusColor, Color cardColor) {
    bool isAssigned = assignedPlantId == id;
    const neonGreen = Color(0xFF00E676);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAssigned ? neonGreen.withOpacity(0.5) : Colors.white10, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.eco_outlined, color: neonGreen, size: 24),
              if (isAssigned)
                const Icon(Icons.pets, color: neonGreen, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, 
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          Text(status, 
            style: GoogleFonts.poppins(color: statusColor, fontSize: 12)),
          
          const Spacer(),
          
          const Divider(color: Colors.white10),
          
          // Toggle Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("Link Pet", 
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10)),
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isAssigned,
                  activeColor: neonGreen,
                  inactiveTrackColor: Colors.white10,
                  onChanged: (val) => _handleToggle(id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddCard(Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10, style: BorderStyle.solid),
      ),
      child: const Center(
        child: Icon(Icons.add_circle_outline, color: Colors.white24, size: 40),
      ),
    );
  }
}