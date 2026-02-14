import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GardenStrategyScreen extends StatefulWidget {
  const GardenStrategyScreen({super.key});

  @override
  State<GardenStrategyScreen> createState() => _GardenStrategyScreenState();
}

class _GardenStrategyScreenState extends State<GardenStrategyScreen> {
  // State Variables
  String _containerSize = "Medium";
  String _experienceLevel = "Beginner";
  final List<String> _selectedCrops = [];

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const bgColor = Color(0xFF121413);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Final Details.",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Customize your garden plan based on your space and goals.",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}