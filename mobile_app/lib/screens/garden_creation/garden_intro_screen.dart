import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'garden_basics_screen.dart';

class GardenIntroScreen extends StatelessWidget {
  const GardenIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF121413);
    const accentGreen = Color(0xFF00E676);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Top badge with a modern AI icon
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentGreen.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome, 
                    color: accentGreen, 
                    size: 40
                  ),
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Bold left-aligned typography
              Text(
                "Let's build your\nsmart garden.",
                style: GoogleFonts.poppins(
                  fontSize: 34, 
                  fontWeight: FontWeight.w800, 
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              
              const SizedBox(height: 12),
              Text(
                "We need a few details to optimize your growth.",
                style: GoogleFonts.poppins(
                  color: Colors.white38, 
                  fontSize: 14
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Feature list
              _buildReasonRow(
                Icons.psychology_outlined, 
                "AI Calibration", 
                "Tailors growth algorithms to your specific soil and light.", 
                accentGreen
              ),
              const SizedBox(height: 24),
              _buildReasonRow(
                Icons.timer_outlined, 
                "Smart Scheduling", 
                "Calculates watering needs based on your setup.", 
                accentGreen
              ),
              const SizedBox(height: 24),
              
              // UPDATED: Changed from Pets to Grass icon for a Plant Pet
              _buildReasonRow(
                Icons.grass, 
                "Live Companion", 
                "Syncs your digital plant's mood with its real-world health.", 
                accentGreen
              ),
              
              const Spacer(),

              // Primary Action
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const GardenBasicsScreen())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)
                    ),
                  ),
                  child: Text(
                    "Create My Garden",
                    style: GoogleFonts.poppins(
                      color: Colors.black, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),

              // Skip option
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const PlaceholderMainScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    "Setup later",
                    style: GoogleFonts.poppins(
                      color: Colors.white24, 
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Row builder with improved alignment
  Widget _buildReasonRow(IconData icon, String title, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: GoogleFonts.poppins(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 15
                )
              ),
              const SizedBox(height: 2),
              Text(
                desc, 
                style: GoogleFonts.poppins(
                  color: Colors.white38, 
                  fontSize: 12, 
                  height: 1.4
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Temporary Placeholder
class PlaceholderMainScreen extends StatelessWidget {
  const PlaceholderMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121413),
      body: Center(
        child: Text(
          "Main Dashboard Coming Soon",
          style: GoogleFonts.poppins(color: Colors.white54),
        ),
      ),
    );
  }
}