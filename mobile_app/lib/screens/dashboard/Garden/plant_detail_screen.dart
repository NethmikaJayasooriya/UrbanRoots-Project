import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../leaf_disease_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isSavingTask = false;

  @override
  void initState() {
    super.initState();
    if (widget.plant['daily_tasks'] != null &&
        (widget.plant['daily_tasks'] as List).isNotEmpty) {
      _tasks = List<Map<String, dynamic>>.from(widget.plant['daily_tasks']);
    } else {
      // Fallback placeholder tasks shown when AI hasn't generated any yet
      _tasks = [
        {"time": "08:30 AM", "title": "Morning Watering", "isDone": true},
        {"time": "12:00 PM", "title": "Check Sunlight Exposure", "isDone": false},
        {"time": "06:00 PM", "title": "Inspect Leaves for Pests", "isDone": false},
      ];
    }
  }

  // Computed helpers
  int get _doneCount => _tasks.where((t) => t['isDone'] == true).length;
  double get _progressValue =>
      _tasks.isEmpty ? 0.0 : _doneCount / _tasks.length;

  bool get _isIoTConnected =>
      widget.plant['is_iot_connected'] == true;

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    setState(() {
      task['isDone'] = !(task['isDone'] as bool? ?? false);
      _isSavingTask = true;
    });

    final int gardenId = await ApiService.getStoredGardenId() ?? 7;
    final int cropId = int.tryParse(widget.plant['id'].toString()) ?? 0;

    if (cropId > 0) {
      await ApiService.updateCropTasks(gardenId, cropId, _tasks);
    }

    if (mounted) setState(() => _isSavingTask = false);
  }

  @override
  Widget build(BuildContext context) {
    final String plantName =
        widget.plant['plant_name'] ?? widget.plant['name'] ?? 'Details';

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
          plantName,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // Subtle saving indicator — appears only while a task is being persisted
        actions: [
          if (_isSavingTask)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                    color: AppColors.primaryGreen, strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sensor tiles ─────────────────────────────────────────────────
            _sectionHeader("Live Environment"),
            const SizedBox(height: 16),
            _isIoTConnected
                ? Row(
                    children: [
                      _buildSensorTile(
                          "Moisture", "42%", Icons.water_drop, true),
                      const SizedBox(width: 12),
                      _buildSensorTile(
                          "Sunlight", "75%", Icons.wb_sunny, true),
                    ],
                  )
                : _buildNoIoTBanner(),
            const SizedBox(height: 32),

            // ── Tasks section header + progress ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _sectionHeader("Daily Tasks"),
                // Progress pill: "2 / 3 done"
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _progressValue == 1.0
                        ? AppColors.primaryGreen.withOpacity(0.15)
                        : AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _progressValue == 1.0
                          ? AppColors.primaryGreen.withOpacity(0.4)
                          : Colors.white10,
                    ),
                  ),
                  child: Text(
                    _progressValue == 1.0
                        ? "All done ✓"
                        : "$_doneCount / ${_tasks.length} done",
                    style: GoogleFonts.poppins(
                      color: _progressValue == 1.0
                          ? AppColors.primaryGreen
                          : Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress bar for overall task completion
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progressValue,
                minHeight: 5,
                backgroundColor: AppColors.surfaceColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _progressValue == 1.0
                      ? AppColors.primaryGreen
                      : AppColors.primaryGreen.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Task cards
            ..._tasks.map((task) => _buildTaskCard(task)),

            const SizedBox(height: 32),

            // ── Leaf health scan CTA ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.filter_center_focus_rounded,
                          color: AppColors.primaryGreen.withOpacity(0.2),
                          size: 60),
                      const Icon(Icons.eco_rounded,
                          color: AppColors.primaryGreen, size: 30),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Leaf Health Scan",
                    style: GoogleFonts.poppins(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Analyze leaves for targeted $plantName diseases.",
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.poppins(color: AppColors.textDim, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeafScanScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_rounded,
                          color: Colors.black, size: 20),
                      label: Text(
                        "Scan Leaf Now",
                        style: GoogleFonts.poppins(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
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

  // Shown when no IoT sensor is connected — replaces the live data tiles
  Widget _buildNoIoTBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sensors_off_rounded,
                color: Colors.white38, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No Sensor Connected",
                  style: GoogleFonts.poppins(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Connect an IoT sensor to see live soil moisture and sunlight data.",
                  style: GoogleFonts.poppins(
                      color: AppColors.textDim, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final bool isDone = task['isDone'] as bool? ?? false;

    return GestureDetector(
      onTap: () => _toggleTask(task),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone
              ? AppColors.primaryGreen.withOpacity(0.06)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone
                ? AppColors.primaryGreen.withOpacity(0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['time'] ?? '',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task['title'] ?? '',
                    style: GoogleFonts.poppins(
                      color: isDone ? Colors.white38 : AppColors.textMain,
                      fontWeight: FontWeight.bold,
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white38,
                    ),
                    softWrap: true,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isDone ? Icons.check_circle : Icons.circle_outlined,
                  key: ValueKey(isDone),
                  color: isDone ? AppColors.primaryGreen : Colors.white10,
                ),
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
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSensorTile(
      String label, String value, IconData icon, bool isLive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
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
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                  color: AppColors.textDim, fontSize: 11),
            ),
            if (isLive) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Live",
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}