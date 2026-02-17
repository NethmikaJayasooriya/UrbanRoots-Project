import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'garden_strategy_screen.dart';

class ManualEnvironmentScreen extends StatefulWidget {
  const ManualEnvironmentScreen({super.key});

  @override
  State<ManualEnvironmentScreen> createState() => _ManualEnvironmentScreenState();
}

class _ManualEnvironmentScreenState extends State<ManualEnvironmentScreen> {
  String _selectedSoil = "Potting Mix";
  double _sunlightValue = 50;
  String _wateringFrequency = "Daily";
  bool _isWindy = false;

  final List<Map<String, String>> _soilTypes = [
    {"name": "Potting Mix", "desc": "High Nutrients, Balanced"},
    {"name": "Red Soil", "desc": "Garden Soil, Acidic"},
    {"name": "Sandy / Beach", "desc": "Low Nutrients, Drains Well"},
    {"name": "Compost", "desc": "Organic, High Nitrogen"},
  ];

  final List<String> _wateringOptions = ["Daily", "Every 2 Days", "Weekly"];

  // helper for sunlight label
  Map<String, dynamic> _getSunlightInfo() {
    if (_sunlightValue < 30) return {"label": "Shadow / Low Light", "icon": Icons.cloud};
    if (_sunlightValue < 70) return {"label": "Partial Sun", "icon": Icons.wb_cloudy};
    return {"label": "Direct Sunlight", "icon": Icons.wb_sunny};
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF121413);
    const surfaceColor = Color(0xFF1E2220);
    const neonGreen = Color(0xFF00E676);
    final sunInfo = _getSunlightInfo();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Describe your\nEnvironment.", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
              const SizedBox(height: 10),
              Text("Since you don't have a sensor, we need a few more details to calibrate the AI.", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 30),

              _sectionTitle("1. Soil Source", neonGreen),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _soilTypes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4),
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
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: neonGreen, width: 2) : null,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(type["name"]!, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: neonGreen),
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

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle("2. Typical Sunlight", neonGreen), Icon(sunInfo["icon"], color: Colors.white, size: 24)]),
              Text(sunInfo["label"], style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(activeTrackColor: neonGreen, inactiveTrackColor: surfaceColor, thumbColor: Colors.white),
                child: Slider(value: _sunlightValue, min: 0, max: 100, divisions: 10, onChanged: (v) => setState(() => _sunlightValue = v)),
              ),
              const SizedBox(height: 30),

              _sectionTitle("3. Watering Frequency", neonGreen),
              const SizedBox(height: 15),
              
              // NEW LAYOUT: Segmented Buttons (Stable and clean)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
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
                            color: isSelected ? neonGreen : Colors.transparent,
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

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("High Wind Exposure?", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text("Usually for balconies above 3rd floor", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Switch(value: _isWindy, activeColor: neonGreen, onChanged: (v) => setState(() => _isWindy = v)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GardenStrategyScreen())),
                  style: ElevatedButton.styleFrom(backgroundColor: neonGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

  Widget _sectionTitle(String text, Color color) {
    return Text(text, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w600, fontSize: 16));
  }
}