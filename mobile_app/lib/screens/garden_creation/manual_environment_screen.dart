import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'garden_strategy_screen.dart';
import 'package:mobile_app/core/theme/app_colors.dart';

class ManualEnvironmentScreen extends StatefulWidget {
  const ManualEnvironmentScreen({super.key});

  @override
  State<ManualEnvironmentScreen> createState() => _ManualEnvironmentScreenState();
}

class _ManualEnvironmentScreenState extends State<ManualEnvironmentScreen> {
  // Variables to store user choices
  String _selectedSoil = "Potting Mix";
  double _sunlightValue = 50;
  String _wateringFrequency = "Daily";
  bool _isWindy = false;

  // Data for the soil selection cards
  final List<Map<String, String>> _soilTypes = [
    {"name": "Potting Mix", "desc": "High Nutrients, Balanced"},
    {"name": "Red Soil", "desc": "Garden Soil, Acidic"},
    {"name": "Sandy / Beach", "desc": "Low Nutrients, Drains Well"},
    {"name": "Compost", "desc": "Organic, High Nitrogen"},
  ];

  final List<String> _wateringOptions = ["Daily", "Every 2 Days", "Weekly"];

  // Dynamically changes the sunlight icon and text based on slider position
  Map<String, dynamic> _getSunlightInfo() {
    if (_sunlightValue < 30) return {"label": "Shadow / Low Light", "icon": Icons.cloud};
    if (_sunlightValue < 70) return {"label": "Partial Sun", "icon": Icons.wb_cloudy};
    return {"label": "Direct Sunlight", "icon": Icons.wb_sunny};
  }

  @override
  Widget build(BuildContext context) {
    final sunInfo = _getSunlightInfo();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Describe your\nEnvironment.", 
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textMain, height: 1.2)
              ),
              const SizedBox(height: 10),
              
              // RED WARNING NOTICE to push users toward IoT devices eventually
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                      "Note: Manual input may reduce the accuracy of the app's AI features compared to real-time data from IoT sensors.",
                        style: GoogleFonts.poppins(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              _sectionTitle("1. Soil Source"),
              const SizedBox(height: 15),
              
              // Soil Types Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _soilTypes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 12, 
                  mainAxisSpacing: 12, 
                  childAspectRatio: 1.4
                ),
                itemBuilder: (context, index) {
                  final type = _soilTypes[index];
                  final isSelected = _selectedSoil == type["name"];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSoil = type["name"]!),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: AppColors.primaryGreen, width: 2) : null,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(type["name"]!, style: GoogleFonts.poppins(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(type["desc"]!, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 8, right: 8,
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryGreen),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(Icons.check, size: 12, color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // Sunlight Slider Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  _sectionTitle("2. Typical Sunlight"), 
                  Icon(sunInfo["icon"], color: AppColors.textMain, size: 24)
                ]
              ),
              Text(sunInfo["label"], style: GoogleFonts.poppins(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primaryGreen, 
                  inactiveTrackColor: AppColors.surfaceColor, 
                  thumbColor: Colors.white
                ),
                child: Slider(
                  value: _sunlightValue, 
                  min: 0, 
                  max: 100, 
                  divisions: 10, 
                  onChanged: (v) => setState(() => _sunlightValue = v)
                ),
              ),
              const SizedBox(height: 30),

              _sectionTitle("3. Watering Frequency"),
              const SizedBox(height: 15),
              
              // Segmented selection for watering habits
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: _wateringOptions.map((opt) {
                    bool isSelected = _wateringFrequency == opt;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _wateringFrequency = opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              opt,
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              // Toggle for wind exposure
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("High Wind Exposure?", style: GoogleFonts.poppins(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text("Usually for balconies above 3rd floor", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Switch(value: _isWindy, activeColor: AppColors.primaryGreen, onChanged: (v) => setState(() => _isWindy = v)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Button to move to the Strategy screen
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GardenStrategyScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: Text("Next Step", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 16));
  }
}