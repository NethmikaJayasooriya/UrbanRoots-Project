import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  // Tickable Task Logic
  final List<Map<String, dynamic>> _tasks = [
    {"time": "08:30 AM", "title": "Morning Watering", "isDone": true},
    {"time": "12:00 PM", "title": "Check Sunlight", "isDone": false},
    {"time": "06:00 PM", "title": "Leaf Cleaning", "isDone": false},
  ];

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF07160F);
    const surfaceColor = Color(0xFF16201B);
    const neonGreen = Color(0xFF00E676);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.plant['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("Live IoT Sensor", neonGreen),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSensorTile("Moisture", "42%", Icons.water_drop, surfaceColor, neonGreen),
                const SizedBox(width: 12),
                _buildSensorTile("Sunlight", "75%", Icons.wb_sunny, surfaceColor, neonGreen),
              ],
            ),
            const SizedBox(height: 32),

            _sectionHeader("Daily Tasks", neonGreen),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return GestureDetector(
                  onTap: () => setState(() => task['isDone'] = !task['isDone']),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor, 
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: task['isDone'] ? neonGreen.withOpacity(0.4) : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task['time'], style: GoogleFonts.poppins(color: neonGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                            Text(task['title'], 
                              style: GoogleFonts.poppins(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                decoration: task['isDone'] ? TextDecoration.lineThrough : null)),
                          ],
                        ),
                        const Spacer(),
                        Icon(task['isDone'] ? Icons.check_circle : Icons.circle_outlined, 
                          color: task['isDone'] ? neonGreen : Colors.white10),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // UNDERSTANDABLE LEAF SCANNER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor, 
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: neonGreen.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.filter_center_focus_rounded, color: neonGreen.withOpacity(0.2), size: 60),
                      const Icon(Icons.eco_rounded, color: neonGreen, size: 30),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("Leaf Health Scan", 
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Analyze leaves for targeted ${widget.plant['name']} diseases.", 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {}, 
                      icon: const Icon(Icons.camera_rounded, color: Colors.black, size: 20),
                      label: Text("Scan Leaf Now", 
                        style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonGreen, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Text(title.toUpperCase(), style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.5));
  }

  Widget _buildSensorTile(String label, String value, IconData icon, Color surface, Color green) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Icon(icon, color: green, size: 20),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}