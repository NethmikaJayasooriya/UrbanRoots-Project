import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../leaf_disease_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _tasks = [];
  bool _isSavingTask = false;

  // ── IoT & Live Sensor Data ─────────────────────────────────────────────────
  bool _isIoTConnected = false;
  String? _iotIp;
  Timer? _iotTimer;
  Map<String, dynamic>? _liveIotData;

  // ── Digital Pet State ──────────────────────────────────────────────────────
  String _petMood = 'idle'; // 'idle', 'happy', 'sad'
  String _petMessage = "I'm doing well! 🌱";
  String _petSubtext = "staying healthy";
  bool _isPetThirsty = false; // Used to color the speech bubble red
  bool _isPetTapped = false;

  AnimationController? _petController;
  late AnimationController _bubbleController;
  late AnimationController _glowController;
  late AnimationController _bounceController;
  late AnimationController _shimmerController;

  late Animation<double> _bubbleFade;
  late Animation<Offset> _bubbleSlide;
  late Animation<double> _glowPulse;
  late Animation<double> _bounceAnim;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    if (widget.plant['daily_tasks'] != null &&
        (widget.plant['daily_tasks'] as List).isNotEmpty) {
      _tasks = List<Map<String, dynamic>>.from(widget.plant['daily_tasks']);
    } else {
      _tasks = [
        {"time": "08:30 AM", "title": "Morning Watering", "isDone": true},
        {"time": "12:00 PM", "title": "Check Sunlight Exposure", "isDone": false},
        {"time": "06:00 PM", "title": "Inspect Leaves for Pests", "isDone": false},
      ];
    }

    // Initialize pet animations
    _initAnimations();

    _isIoTConnected = widget.plant['is_iot_connected'] == true;
    if (_isIoTConnected) {
      _initIoT();
    } else {
      _evaluateNormalPetLogic();
    }
  }

  void _initAnimations() {
    _bubbleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _bubbleFade =
        CurvedAnimation(parent: _bubbleController, curve: Curves.easeOut);
    _bubbleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bubbleController, curve: Curves.easeOut));

    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _bounceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0.0, end: -5.0)
        .animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));

    _bubbleController.forward();
  }

  Future<void> _initIoT() async {
    final prefs = await SharedPreferences.getInstance();
    _iotIp = prefs.getString('iot_device_ip');

    if (_iotIp != null) {
      _startIoTPolling();
    } else {
      // Configured for IoT but IP missing
      _evaluateNormalPetLogic();
    }
  }

  void _startIoTPolling() {
    _iotTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted) return;
      try {
        final res = await http
            .get(Uri.parse('http://$_iotIp/data'))
            .timeout(const Duration(milliseconds: 1500));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (mounted) {
            setState(() {
              _liveIotData = data;
              _evaluateIoTPetLogic(data);
            });
          }
        }
      } catch (e) {
        // Just silently fail if sensor drops a ping
      }
    });
  }

  // Live Instant Reaction Logic from Hardware Sensor
  void _evaluateIoTPetLogic(Map<String, dynamic> data) {
    if (_isPetTapped) return; // Don't interrupt if user just tapped

    final double temp = (data['temp'] as num?)?.toDouble() ?? 25.0;
    final double moisture = (data['moisture'] as num?)?.toDouble() ?? 50.0;

    String nextMood = 'idle';
    String nextMsg = '';
    String nextSub = '';
    bool nextThirsty = false;

    if (temp > 35) {
      nextMood = 'sad';
      nextMsg = "It's boiling! Please cool me down! 🥵";
      nextSub = "Temp is ${temp.toStringAsFixed(1)}°C";
      nextThirsty = true;
    } else if (temp < 10) {
      nextMood = 'sad';
      nextMsg = "I'm freezing in here! 🥶";
      nextSub = "Temp is ${temp.toStringAsFixed(1)}°C";
      nextThirsty = true;
    } else if (moisture < 20) {
      nextMood = 'sad';
      nextMsg = "I'm incredibly thirsty! Give me water! 💧";
      nextSub = "Moisture is ${moisture.toStringAsFixed(0)}%";
      nextThirsty = true;
    } else if (moisture > 80) {
      nextMood = 'sad';
      nextMsg = "Too much water! My roots are drowning! 🧊";
      nextSub = "Moisture is ${moisture.toStringAsFixed(0)}%";
      nextThirsty = true;
    } else {
      nextMood = 'idle';
      nextMsg = "Ahhh... perfect conditions! 🌱";
      nextSub = "Temp & moisture optimal";
      nextThirsty = false;
    }

    if (_petMood != nextMood || _petMessage != nextMsg) {
      _petMood = nextMood;
      _petMessage = nextMsg;
      _petSubtext = nextSub;
      _isPetThirsty = nextThirsty;
      _triggerBubbleAnimation();
    }
  }

  // Fallback Logic when IoT disconnected
  void _evaluateNormalPetLogic() {
    if (_isPetTapped) return;
    String nextMood = 'idle';
    String nextMsg = '';
    String nextSub = '';

    if (_progressValue == 1.0 && _tasks.isNotEmpty) {
      nextMood = 'happy';
      nextMsg = "All my tasks are done! ✨";
      nextSub = "You're the best!";
    } else if (_doneCount == 0 && _tasks.isNotEmpty) {
      nextMood = 'idle';
      nextMsg = "I have some tasks for you! 📝";
      nextSub = "Check below";
    } else {
      nextMood = 'idle';
      nextMsg = "Almost there! Keep going! 🌱";
      nextSub = "$_doneCount/${_tasks.length} tasks done";
    }

    if (_petMood != nextMood || _petMessage != nextMsg) {
      _petMood = nextMood;
      _petMessage = nextMsg;
      _petSubtext = nextSub;
      _isPetThirsty = false;
      _triggerBubbleAnimation();
    }
  }

  @override
  void dispose() {
    _iotTimer?.cancel();
    _bubbleController.dispose();
    _glowController.dispose();
    _bounceController.dispose();
    _shimmerController.dispose();
    _petController?.dispose();
    super.dispose();
  }

  int get _doneCount => _tasks.where((t) => t['isDone'] == true).length;
  double get _progressValue => _tasks.isEmpty ? 0.0 : _doneCount / _tasks.length;

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    setState(() {
      task['isDone'] = !(task['isDone'] as bool? ?? false);
      _isSavingTask = true;
    });

    if (!_isIoTConnected) _evaluateNormalPetLogic(); // Re-eval tasks

    final int gardenId = await ApiService.getStoredGardenId() ?? 7;
    final int cropId = int.tryParse(widget.plant['id'].toString()) ?? 0;

    if (cropId > 0) {
      await ApiService.updateCropTasks(gardenId, cropId, _tasks);
    }
    if (mounted) setState(() => _isSavingTask = false);
  }

  void _triggerBubbleAnimation() {
    _bubbleController.reset();
    _bubbleController.forward();
  }

  void _handlePetTap() async {
    if (_isPetTapped || _isPetThirsty) return;
    setState(() {
      _isPetTapped = true;
      _petMood = 'happy';
      _petMessage = "Yay! Pets! 🥰";
      _petSubtext = "feeling loved";
    });
    _triggerBubbleAnimation();

    if (_petController != null) {
      const double jumpSeekPosition = 0.06;
      _petController!.value = jumpSeekPosition;
      _petController!.forward();
    }

    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _isPetTapped = false);
      if (_isIoTConnected && _liveIotData != null) {
        _evaluateIoTPetLogic(_liveIotData!);
      } else {
        _evaluateNormalPetLogic();
      }
    }
  }

  String _getPetAnimation() {
    if (_petMood == 'sad') return 'assets/animations/pet_sad.json';
    if (_petMood == 'happy' || _isPetTapped) return 'assets/animations/pet_happy.json';
    return 'assets/animations/pet_idle.json';
  }

  Color get _accentColor => _isPetThirsty ? Colors.redAccent : AppColors.primaryGreen;

  List<Color> get _bubbleGradient => _isPetThirsty
      ? [const Color(0xFF2D1515), const Color(0xFF1A0C0C)]
      : _isPetTapped
          ? [const Color(0xFF1E2D1A), const Color(0xFF0F1A0C)]
          : [const Color(0xFF162214), const Color(0xFF0D180B)];

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
            // ── Live Interactive Pet Area ────────────────────────────────────
            SizedBox(
              height: 250,
              width: double.infinity,
              child: _buildPetArea(),
            ),
            const SizedBox(height: 20),

            // ── Sensor tiles ─────────────────────────────────────────────────
            _sectionHeader("Live Environment"),
            const SizedBox(height: 16),
            _isIoTConnected
                ? Row(
                    children: [
                      _buildSensorTile(
                          "Moisture",
                          _liveIotData != null ? "${_liveIotData!['moisture']}%" : "--%",
                          Icons.water_drop,
                          true),
                      const SizedBox(width: 12),
                      _buildSensorTile(
                          "Temp",
                          _liveIotData != null ? "${_liveIotData!['temp']}°C" : "--°C",
                          Icons.thermostat,
                          true),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

            ..._tasks.map((task) => _buildTaskCard(task)),

            const SizedBox(height: 32),
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
                    style: GoogleFonts.poppins(
                        color: AppColors.textDim, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LeafScanScreen()),
                      ),
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

  // ── Pet Sub-Widgets ────────────────────────────────────────────────────────
  Widget _buildPetArea() {
    const double idleYOffset = 28.0;
    const double sadYOffset = 28.0;
    const double happyYOffset = 0.0;

    bool isHappyState = _petMood == 'happy' || _isPetTapped;
    double petScale = isHappyState ? 1.15 : 1.05;
    double yOffset = isHappyState
        ? happyYOffset
        : (_petMood == 'sad' ? sadYOffset : idleYOffset);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: _handlePetTap,
                    child: Transform.translate(
                      offset: Offset(0, yOffset),
                      child: Transform.scale(
                        scale: petScale,
                        alignment: Alignment.bottomCenter,
                        child: Lottie.asset(
                          _getPetAnimation(),
                          key: ValueKey(_isPetTapped ? 'tapped' : _getPetAnimation()),
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          controller: _isPetTapped && !_isPetThirsty ? _petController : null,
                          onLoaded: (composition) {
                            if (_isPetTapped && !_isPetThirsty) {
                              _petController?.dispose();
                              _petController = AnimationController(
                                vsync: this,
                                duration: composition.duration,
                              );
                              _petController!.value = 0.06;
                              _petController!.forward();
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _bubbleFade,
                  child: SlideTransition(
                    position: _bubbleSlide,
                    child: AnimatedBuilder(
                      animation: _bounceAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _bounceAnim.value),
                        child: child,
                      ),
                      child: _buildSpeechBubble(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeechBubble() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200, minWidth: 140),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_glowPulse, _shimmerAnim]),
            builder: (_, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _bubbleGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _accentColor.withOpacity(_glowPulse.value),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(_glowPulse.value * 0.45),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.55),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment(_shimmerAnim.value - 1, 0),
                            end: Alignment(_shimmerAnim.value, 0),
                            colors: const [
                              Colors.transparent,
                              Colors.white10,
                              Colors.transparent,
                            ],
                          ).createShader(bounds),
                          child: Container(color: Colors.white),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _StatusDot(color: _accentColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _petMessage,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 2),
                          child: Text(
                            _petSubtext,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: GoogleFonts.poppins(
                              color: _accentColor.withOpacity(0.75),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: CustomPaint(
              size: const Size(22, 14),
              painter: _BubbleTailPainter(
                fillColor: _bubbleGradient.last,
                borderColor: _accentColor.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
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
                  "Connect an IoT sensor to unlock live digital pet reactions.",
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
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white38,
                    ),
                    maxLines: 4,
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

  Widget _buildSensorTile(String label, String value, IconData icon, bool isLive) {
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
              style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 11),
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
                    "Live from hardware",
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen,
                      fontSize: 8,
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

class _StatusDot extends StatefulWidget {
  final Color color;
  const _StatusDot({required this.color});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(_pulse.value),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_pulse.value * 0.6),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  const _BubbleTailPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height * 0.3)
      ..close();

    canvas.drawPath(
        path, Paint()..color = fillColor..style = PaintingStyle.fill);
    canvas.drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter old) =>
      old.fillColor != fillColor || old.borderColor != borderColor;
}