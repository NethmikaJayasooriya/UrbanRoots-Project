import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/services/api_service.dart';
import 'leaf_disease_screen.dart'; // <-- ADDED: Imports your teammate's ML scanner

class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    
    if (widget.plant['daily_tasks'] != null) {
      _tasks = List<Map<String, dynamic>>.from(widget.plant['daily_tasks']);
    } else {
      _tasks = [
        {"time": "08:30 AM", "title": "Morning Watering", "isDone": true},
        {"time": "12:00 PM", "title": "Check Sunlight", "isDone": false},
        {"time": "06:00 PM", "title": "Leaf Cleaning", "isDone": false},
      ];
    }
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    setState(() => task['isDone'] = !task['isDone']);
    
    int gardenId = await ApiService.getStoredGardenId() ?? 7;
    int cropId = int.tryParse(widget.plant['id'].toString()) ?? 0;
    
    if (cropId > 0) {
      await ApiService.updateCropTasks(gardenId, cropId, _tasks);
    }
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
          widget.plant['name'] ?? 'Details', 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("Live IoT Sensor"),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSensorTile("Moisture", "42%", Icons.water_drop),
                const SizedBox(width: 12),
                _buildSensorTile("Sunlight", "75%", Icons.wb_sunny),
              ],
            ),
            const SizedBox(height: 32),

            _sectionHeader("Daily Tasks"),
            const SizedBox(height: 16),
            ..._tasks.map((task) => _buildTaskCard(task)),
            
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor, 
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.filter_center_focus_rounded, color: AppColors.primaryGreen.withOpacity(0.2), size: 60),
                      const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 30),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Leaf Health Scan", 
                    style: GoogleFonts.poppins(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Analyze leaves for targeted ${widget.plant['name']} diseases.", 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 12)
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // <-- ADDED: Actually navigates to the scanner when tapped!
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeafScanScreen(),
                          ),
                        );
                      }, 
                      icon: const Icon(Icons.camera_rounded, color: Colors.black, size: 20),
                      label: Text(
                        "Scan Leaf Now", 
                        style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return GestureDetector(
      onTap: () => _toggleTask(task), 
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor, 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: task['isDone'] 
                ? AppColors.primaryGreen.withOpacity(0.4) 
                : Colors.transparent
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to top for multi-line text
          children: [
            // Expanded forces the column to respect screen bounds and wrap text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['time'] ?? '', 
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 11
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task['title'] ?? '', 
                    style: GoogleFonts.poppins(
                      color: AppColors.textMain, 
                      fontWeight: FontWeight.bold,
                      decoration: task['isDone'] ? TextDecoration.lineThrough : null
                    ),
                    softWrap: true, // Forces text to wrap
                    maxLines: 4,    // Allows AI to generate longer, specific tasks
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(
                task['isDone'] ? Icons.check_circle : Icons.circle_outlined, 
                color: task['isDone'] ? AppColors.primaryGreen : Colors.white10
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(), 
      style: GoogleFonts.poppins(
        color: AppColors.primaryGreen, 
        fontWeight: FontWeight.w800, 
        fontSize: 11, 
        letterSpacing: 1.5
      )
    );
  }

  Widget _buildSensorTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor, 
          borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 20),
            const SizedBox(height: 8),
            Text(
              value, 
              style: GoogleFonts.poppins(
                color: AppColors.textMain, 
                fontWeight: FontWeight.bold, 
                fontSize: 18
              )
            ),
            Text(
              label, 
              style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 11)
            ),
          ],
        ),
      ),
    );
  }
}