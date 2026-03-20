import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api_service.dart';

import '../../garden_creation/iot_connection_screen.dart';

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

  // ── Extended pet state (new) ───────────────────────────────────────────────
  bool _isPetWarning = false;       // orange accent — borderline sensor values
  String _previousMood = 'idle';    // for recovery celebration detection
  bool _sensorConnected = true;     // live signal health indicator
  int _failStreak = 0;              // consecutive HTTP poll failures
  static const int _maxFailStreak = 4; // 4 x 2s = 8s before signal-lost state
  final List<Map<String, dynamic>> _alertLog = [];  // last 5 sensor events
  String _lastAlertType = '';       // prevents duplicate log entries
  int _gardenId = 0;                  // loaded in initState for API calls

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
    // Load stored garden ID so _writeAlertToPrefs can call the backend
    ApiService.getStoredGardenId().then((id) {
      if (id != null && mounted) setState(() => _gardenId = id);
    });
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

  // ── Assign IoT to this plant from Plant Detail Screen ─────────────────────
  Future<void> _assignIoT() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('iot_device_ip');

    if (savedIp != null && savedIp.isNotEmpty) {
      // IP already stored — activate polling instantly for this plant
      if (mounted) {
        setState(() {
          _isIoTConnected = true;
          _iotIp = savedIp;
          _sensorConnected = true;
          _failStreak = 0;
        });
        _startIoTPolling();
        _showIoTSnack('🌱 Sensor activated! Your pet will now react to live data.', AppColors.primaryGreen);
      }
    } else {
      // No device configured yet — open the IoT connection screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IoTConnectionScreen(
            gardenData: null,
            onGardenCreated: null,
          ),
        ),
      );
      // After returning, check if an IP was saved
      if (!mounted) return;
      final newPrefs = await SharedPreferences.getInstance();
      final newIp = newPrefs.getString('iot_device_ip');
      if (newIp != null && newIp.isNotEmpty && mounted) {
        setState(() {
          _isIoTConnected = true;
          _iotIp = newIp;
          _sensorConnected = true;
          _failStreak = 0;
        });
        _startIoTPolling();
        _showIoTSnack('🌱 Sensor linked! Your pet is now monitoring this plant.', AppColors.primaryGreen);
      }
    }
  }

  // ── Deactivate IoT for this plant (does NOT delete the saved IP) ──────────
  void _deactivateIoT() {
    _iotTimer?.cancel();
    if (mounted) {
      setState(() {
        _isIoTConnected = false;
        _liveIotData = null;
        _sensorConnected = true;
        _failStreak = 0;
      });
      _evaluateNormalPetLogic();
      _showIoTSnack('Sensor disconnected from this plant.', Colors.orange);
    }
  }

  void _showIoTSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.poppins()),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  void _startIoTPolling() {
    // BUG FIX 3: Cancel any existing timer before starting a new one.
    // Without this, every call to _assignIoT / _initIoT stacked a new
    // parallel timer, causing back-to-back HTTP requests that overwhelm 
    // the ESP32 WebServer — making the sensor appear to constantly
    // disconnect and reconnect in the app.
    _iotTimer?.cancel();
    _iotTimer = null;

    bool _polling = false; // guard against overlapping requests
    _iotTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || _polling) return;
      _polling = true;
      try {
        final res = await http
            .get(Uri.parse('http://$_iotIp/data'))
            .timeout(const Duration(milliseconds: 2500));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (mounted) {
            setState(() {
              _liveIotData = data;
              _failStreak = 0;
              // If sensor just came back after being lost, celebrate the reconnect
              if (!_sensorConnected) {
                _sensorConnected = true;
                _logAlert('info', '📦 Sensor reconnected');
              }
              _evaluateIoTPetLogic(data);
            });
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _failStreak++;
            if (_failStreak >= _maxFailStreak && _sensorConnected) {
              _sensorConnected = false;
              _logAlert('warning', '📡 Sensor signal lost');
              // BUG FIX 1: Pet should be SAD (not idle) when signal is lost —
              // it mirrors what a real plant would feel: disconnected & worried.
              _petMood = 'sad';
              _petMessage = "I lost contact with my sensor... 📡";
              _petSubtext = "signal lost — check device";
              _isPetThirsty = true;  // red bubble = distress
              _isPetWarning = false;
              _triggerBubbleAnimation();
            }
          });
        }
      } finally {
        _polling = false;
      }
    });
  }

  // ── Live Instant Reaction Logic — 4 real sensors from RS485 + BH1750 ────────
  // Firmware fields: moisture(%), temp(°C), light(raw lux), ph(0-14)
  // ec(μS/cm), n/p/k(mg/kg) are read from data for NPK tiles but don't drive mood.
  // There is NO air humidity sensor on this hardware — that field was removed.
  void _evaluateIoTPetLogic(Map<String, dynamic> data) {
    if (_isPetTapped) return;

    final double temp     = (data['temp']     as num?)?.toDouble() ?? 25.0;
    final double moisture = (data['moisture'] as num?)?.toDouble() ?? 50.0;
    // BH1750 outputs raw lux (0–120,000). Typical indoor = 200–2000, outdoor = 10k–100k
    final double lux      = (data['light']    as num?)?.toDouble() ?? 5000.0;
    // RS485 7-in-1 sensor pH (0–14, optimal for most plants: 5.5–7.0)
    final double ph       = (data['ph']       as num?)?.toDouble() ?? 6.5;

    // BUG FIX 2: Detect night time (8PM – 6AM).
    // Low lux at night is completely normal — the plant is resting and the BH1750
    // will always read near-zero in darkness. Skip ALL light-based alerts at night
    // so the pet doesn't become sad just because the lights are off.
    final int hour = DateTime.now().hour;
    final bool isNightTime = hour >= 20 || hour < 6;

    // ── Evaluate severity (critical wins over warning) ─────────────────────
    bool isCritical = false;
    bool isWarning  = false;
    String alertType = 'normal';
    String nextMsg = '';
    String nextSub = '';

    // CRITICAL checks — highest priority, triggers red sad mood
    if (temp > 38) {
      isCritical = true; alertType = 'overheat';
      nextMsg = "It's scorching! I'm burning up! 🔥";
      nextSub = "Soil temp critical: ${temp.toStringAsFixed(1)}°C";
    } else if (temp < 10) {
      isCritical = true; alertType = 'frost';
      nextMsg = "Freezing! My roots are shutting down! ❄️";
      nextSub = "Soil temp critical: ${temp.toStringAsFixed(1)}°C";
    } else if (moisture > 90) {
      isCritical = true; alertType = 'overwater';
      nextMsg = "DROWNING! My roots can't breathe! 🌊";
      nextSub = "Moisture critical: ${moisture.toStringAsFixed(0)}%";
    } else if (moisture < 10) {
      isCritical = true; alertType = 'drought';
      nextMsg = "Dying of thirst — please water me NOW! 💧";
      nextSub = "Moisture critical: ${moisture.toStringAsFixed(0)}%";
    } else if (!isNightTime && lux < 200) {
      // Skip light checks during night (8PM–6AM) — darkness is expected then
      isCritical = true; alertType = 'dark';
      nextMsg = "Pitch dark! I can't photosynthesize at all! 🌑";
      nextSub = "Light critical: ${lux.toStringAsFixed(0)} lux";
    } else if (ph < 4.5) {
      isCritical = true; alertType = 'acid';
      nextMsg = "Soil is too acidic! My roots are burning! 🧪";
      nextSub = "pH critical: ${ph.toStringAsFixed(1)}";
    } else if (ph > 8.0) {
      isCritical = true; alertType = 'alkaline';
      nextMsg = "Soil too alkaline! Nutrients locked out! ⚗️";
      nextSub = "pH critical: ${ph.toStringAsFixed(1)}";
    }

    // WARNING checks — orange mood, concerned dialogue
    else if (temp > 33) {
      isWarning = true; alertType = 'overheat_warn';
      nextMsg = "Getting pretty hot... watch the temperature. 🌡️";
      nextSub = "Soil temp warning: ${temp.toStringAsFixed(1)}°C";
    } else if (temp < 14) {
      isWarning = true; alertType = 'cold_warn';
      nextMsg = "It's getting chilly in my roots... 🧥";
      nextSub = "Soil temp warning: ${temp.toStringAsFixed(1)}°C";
    } else if (moisture > 78) {
      isWarning = true; alertType = 'overwater_warn';
      nextMsg = "Soil is getting soggy... ease up on water. 💦";
      nextSub = "Moisture warning: ${moisture.toStringAsFixed(0)}%";
    } else if (moisture < 22) {
      isWarning = true; alertType = 'drought_warn';
      nextMsg = "Getting thirsty... please water me soon. 🥤";
      nextSub = "Moisture warning: ${moisture.toStringAsFixed(0)}%";
    } else if (!isNightTime && lux < 1000) {
      // Skip light warning at night — plants don't need light when they're resting
      isWarning = true; alertType = 'dark_warn';
      nextMsg = "Could use more light to grow strong! ☀️";
      nextSub = "Light warning: ${lux.toStringAsFixed(0)} lux";
    } else if (ph < 5.5) {
      isWarning = true; alertType = 'acid_warn';
      nextMsg = "Soil a bit acidic... consider a pH balance. 🌿";
      nextSub = "pH warning: ${ph.toStringAsFixed(1)}";
    } else if (ph > 7.0) {
      isWarning = true; alertType = 'alkaline_warn';
      nextMsg = "Soil slightly alkaline... watch nutrient uptake. 🌾";
      nextSub = "pH warning: ${ph.toStringAsFixed(1)}";
    }

    // NORMAL — all conditions optimal (or nighttime with only light being low)
    else {
      alertType = isNightTime ? 'night' : 'normal';
      nextMsg = isNightTime
          ? "Resting for the night... 🌙 see you tomorrow!"
          : "Ahhh... perfect conditions right now! 🌱";
      nextSub = "${temp.toStringAsFixed(0)}°C · ${moisture.toStringAsFixed(0)}% · pH ${ph.toStringAsFixed(1)}";
    }

    // ── Recovery celebration: was sad → now all clear ──────────────────────
    final bool wasDistressed = _previousMood == 'sad';
    final bool nowNormal     = !isCritical && !isWarning;

    if (wasDistressed && nowNormal) {
      nextMsg = "I feel so much better now! 💚";
      nextSub  = "all conditions restored";
      // Trigger the happy jump — mirrors _handlePetTap logic
      _triggerRecoveryBounce();
      _writeAlertToPrefs(resolved: true);
    } else if (isCritical && _lastAlertType != alertType) {
      // New critical condition: log it and notify Home screen via SharedPreferences
      _logAlert('critical', nextMsg);
      _writeAlertToPrefs(
        alertType: alertType,
        message: nextMsg,
        resolved: false,
        plantName: widget.plant['plant_name'] ?? widget.plant['name'] ?? 'Plant',
      );
      _lastAlertType = alertType;
    } else if (isWarning && _lastAlertType != alertType) {
      _logAlert('warning', nextMsg);
      _lastAlertType = alertType;
    } else if (nowNormal && _lastAlertType.isNotEmpty && _lastAlertType != 'normal') {
      _logAlert('info', '✅ All conditions back to optimal');
      _lastAlertType = 'normal';
    }

    // Store mood before updating for next cycle's recovery detection
    _previousMood = isCritical ? 'sad' : 'idle';

    final String nextMood  = isCritical ? 'sad' : 'idle';
    final bool nextThirsty = isCritical;
    final bool nextWarn    = isWarning && !isCritical;

    if (_petMood != nextMood || _petMessage != nextMsg) {
      _petMood      = nextMood;
      _petMessage   = nextMsg;
      _petSubtext   = nextSub;
      _isPetThirsty = nextThirsty;
      _isPetWarning = nextWarn;
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

  // ── Recovery bounce: mirrors _handlePetTap but triggered by sensor recovery ─
  void _triggerRecoveryBounce() async {
    setState(() {
      _isPetTapped = true;
      _petMood = 'happy';
    });
    if (_petController != null) {
      _petController!.value = 0.06;
      _petController!.forward();
    }
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _isPetTapped = false);
      if (_isIoTConnected && _liveIotData != null) {
        _evaluateIoTPetLogic(_liveIotData!);
      }
    }
  }

  // ── Add an entry to the in-memory alert event log (max 5) ─────────────────
  void _logAlert(String type, String message) {
    final now = TimeOfDay.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    _alertLog.insert(0, {'time': '$h:$m', 'type': type, 'message': message});
    if (_alertLog.length > 5) _alertLog.removeRange(5, _alertLog.length);
  }

  // ── Persist alert to SharedPreferences AND call backend for AI dialogue ─────
  Future<void> _writeAlertToPrefs({
    String alertType = '',
    String message   = '',
    String plantName = '',
    required bool resolved,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('iot_alert_resolved', resolved);
      if (!resolved) {
        await prefs.setString('iot_last_alert_type', alertType);
        await prefs.setString('iot_last_alert_message', message);
        await prefs.setString('iot_last_alert_plant', plantName);
        await prefs.setString('iot_last_alert_time', DateTime.now().toIso8601String());

        // Fire-and-forget: ask backend for plant-specific AI dialogue.
        // When the response arrives, update the pet message if we're still
        // showing the same alert (not resolved, not overridden by a new one).
        if (_gardenId > 0 && _liveIotData != null) {
          ApiService.postIoTAlert(_gardenId, {
            'alert_type': alertType,
            'plant_name': plantName,
            'temp':     _liveIotData!['temp'],
            'moisture': _liveIotData!['moisture'],
            'light':    _liveIotData!['light'],
            'ph':       _liveIotData!['ph'],
          }).then((result) {
            if (result != null && mounted && _lastAlertType == alertType) {
              setState(() {
                _petMessage = result['pet_dialogue'] ?? _petMessage;
                // Update the shared pref message so Home screen shows AI text too
                SharedPreferences.getInstance().then((p) {
                  p.setString('iot_last_alert_message', _petMessage);
                });
              });
              _triggerBubbleAnimation();
            }
          });
        }
      }
    } catch (_) {}
  }

  // ── Returns 'critical', 'warning', or 'normal' for a sensor reading ───────
  // All thresholds calibrated to firmware output:
  //   temp = soil °C, moisture = soil %, light = raw BH1750 lux, ph = 0-14
  String _getSensorSeverity(String sensor, Map<String, dynamic>? data) {
    if (data == null) return 'normal';
    switch (sensor) {
      case 'temp':
        final v = (data['temp'] as num?)?.toDouble() ?? 25.0;
        if (v > 38 || v < 10) return 'critical';
        if (v > 33 || v < 14) return 'warning';
        return 'normal';
      case 'moisture':
        final v = (data['moisture'] as num?)?.toDouble() ?? 50.0;
        if (v > 90 || v < 10) return 'critical';
        if (v > 78 || v < 22) return 'warning';
        return 'normal';
      case 'light':
        // BH1750 lux — skip severity at night (8PM–6AM): darkness is expected then.
        final nightHour = DateTime.now().hour;
        final isNight   = nightHour >= 20 || nightHour < 6;
        if (isNight) return 'normal'; // tile stays green at night
        final v = (data['light'] as num?)?.toDouble() ?? 5000.0;
        if (v < 200)  return 'critical';
        if (v < 1000) return 'warning';
        return 'normal';
      case 'ph':
        // RS485 7-in-1 sensor pH: optimal 5.5-7.0 for most edible plants
        final v = (data['ph'] as num?)?.toDouble() ?? 6.5;
        if (v < 4.5 || v > 8.0) return 'critical';
        if (v < 5.5 || v > 7.0) return 'warning';
        return 'normal';
      default:
        return 'normal';
    }
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

  Color get _accentColor {
    if (_isPetThirsty) return Colors.redAccent;
    if (_isPetWarning) return Colors.orange;
    return AppColors.primaryGreen;
  }

  List<Color> get _bubbleGradient => _isPetThirsty
      ? [const Color(0xFF2D1515), const Color(0xFF1A0C0C)]
      : _isPetWarning
          ? [const Color(0xFF2D1E0A), const Color(0xFF1A1205)]
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionHeader("Live Environment"),
                if (_isIoTConnected)
                  Row(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _sensorConnected ? AppColors.primaryGreen : Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                          color: (_sensorConnected ? AppColors.primaryGreen : Colors.orange).withOpacity(0.6),
                          blurRadius: 6, spreadRadius: 1,
                        )],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sensorConnected ? "Live" : "Signal Lost",
                      style: GoogleFonts.poppins(
                        color: _sensorConnected ? AppColors.primaryGreen : Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ── Disconnect / manage button ──────────────────────────
                    GestureDetector(
                      onTap: () => _showDisconnectDialog(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.settings_input_antenna_rounded,
                                color: Colors.white38, size: 11),
                            const SizedBox(width: 3),
                            Text(
                              'Manage',
                              style: GoogleFonts.poppins(
                                color: Colors.white38,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
              ],
            ),
            const SizedBox(height: 16),
            _isIoTConnected
                ? Column(
                    children: [
                      // ── Main 2x2 grid: sensors that drive pet mood ─────────
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.35, // Reduced from 1.55 to prevent bottom layout overflows
                        children: [
                          _buildSensorTile(
                            "Soil Moisture",
                            _liveIotData != null
                                ? "${(_liveIotData!['moisture'] as num?)?.toStringAsFixed(0) ?? '--'}%"
                                : "--%",
                            Icons.water_drop,
                            _getSensorSeverity('moisture', _liveIotData),
                          ),
                          _buildSensorTile(
                            "Soil Temp",
                            _liveIotData != null
                                ? "${(_liveIotData!['temp'] as num?)?.toStringAsFixed(1) ?? '--'}°C"
                                : "--°C",
                            Icons.thermostat,
                            _getSensorSeverity('temp', _liveIotData),
                          ),
                          _buildSensorTile(
                            "Light",
                            _liveIotData != null
                                ? "${(_liveIotData!['light'] as num?)?.toStringAsFixed(0) ?? '--'} lux"
                                : "-- lux",
                            Icons.wb_sunny_outlined,
                            _getSensorSeverity('light', _liveIotData),
                          ),
                          _buildSensorTile(
                            "Soil pH",
                            _liveIotData != null
                                ? "${(_liveIotData!['ph'] as num?)?.toStringAsFixed(1) ?? '--'}"
                                : "--",
                            Icons.science_outlined,
                            _getSensorSeverity('ph', _liveIotData),
                          ),
                        ],
                      ),
                      // ── NPK + EC row: extra data from 7-in-1 RS485 sensor ──
                      if (_liveIotData != null) ...[
                        const SizedBox(height: 12),
                        _buildNpkRow(_liveIotData!),
                      ],
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

            // ── Alert event log ───────────────────────────────────────────────
            if (_alertLog.isNotEmpty) ...[
              const SizedBox(height: 28),
              _buildAlertLog(),
            ],


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

  // ── NPK + EC compact row — uses extra data from the 7-in-1 RS485 sensor ─────
  Widget _buildNpkRow(Map<String, dynamic> data) {
    final int    n  = (data['n']  as num?)?.toInt() ?? 0;
    final int    p  = (data['p']  as num?)?.toInt() ?? 0;
    final int    k  = (data['k']  as num?)?.toInt() ?? 0;
    final int    ec = (data['ec'] as num?)?.toInt() ?? 0;

    Widget _pill(String label, String value, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        _pill("N mg/kg", "$n", const Color(0xFF66BB6A)),
        const SizedBox(width: 8),
        _pill("P mg/kg", "$p", const Color(0xFF42A5F5)),
        const SizedBox(width: 8),
        _pill("K mg/kg", "$k", const Color(0xFFFF7043)),
        const SizedBox(width: 8),
        _pill("EC μS/cm", "$ec", const Color(0xFFAB47BC)),
      ],
    );
  }

  // ── Alert event log widget ────────────────────────────────────────────────
  Widget _buildAlertLog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Sensor Event Log"),
        const SizedBox(height: 12),
        ..._alertLog.map((alert) {
          final Color alertColor = alert['type'] == 'critical'
              ? Colors.redAccent
              : alert['type'] == 'warning'
                  ? Colors.orange
                  : AppColors.primaryGreen;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: alertColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: alertColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: alertColor, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  alert['time'],
                  style: GoogleFonts.poppins(
                    color: alertColor.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    alert['message'],
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildNoIoTBanner() {
    return FutureBuilder<String?>(
      future: SharedPreferences.getInstance()
          .then((p) => p.getString('iot_device_ip')),
      builder: (context, snapshot) {
        final bool hasSavedDevice =
            snapshot.hasData && (snapshot.data?.isNotEmpty ?? false);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasSavedDevice
                  ? AppColors.primaryGreen.withOpacity(0.35)
                  : Colors.white10,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: hasSavedDevice
                          ? AppColors.primaryGreen.withOpacity(0.12)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      hasSavedDevice
                          ? Icons.sensors_rounded
                          : Icons.sensors_off_rounded,
                      color: hasSavedDevice
                          ? AppColors.primaryGreen
                          : Colors.white38,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasSavedDevice
                              ? "Sensor Ready"
                              : "No Sensor Connected",
                          style: GoogleFonts.poppins(
                            color: hasSavedDevice
                                ? AppColors.primaryGreen
                                : AppColors.textMain,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          hasSavedDevice
                              ? "Tap below to activate live monitoring for this plant."
                              : "Connect an IoT sensor to unlock live digital pet reactions.",
                          style: GoogleFonts.poppins(
                              color: AppColors.textDim,
                              fontSize: 11,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── What the pet reacts to ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _iotFeatureChip(Icons.water_drop_outlined, 'Moisture', Colors.blueAccent),
                  _iotFeatureChip(Icons.thermostat_outlined, 'Temp', Colors.orangeAccent),
                  _iotFeatureChip(Icons.wb_sunny_outlined, 'Light', Colors.amber),
                  _iotFeatureChip(Icons.science_outlined, 'pH', Colors.purpleAccent),
                ],
              ),
              const SizedBox(height: 16),

              // ── Action button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _assignIoT,
                  icon: Icon(
                    hasSavedDevice
                        ? Icons.flash_on_rounded
                        : Icons.add_link_rounded,
                    color: Colors.black,
                    size: 18,
                  ),
                  label: Text(
                    hasSavedDevice ? 'Activate Sensor' : 'Connect Sensor',
                    style: GoogleFonts.poppins(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _iotFeatureChip(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ── Disconnect confirm dialog ────────────────────────────────────────────
  void _showDisconnectDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Manage Sensor',
          style: GoogleFonts.poppins(
              color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_iotIp != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sensors_rounded,
                        color: AppColors.primaryGreen, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _iotIp!,
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              'Do you want to disconnect the sensor from this plant? The device will remain saved for other plants.',
              style: GoogleFonts.poppins(
                  color: AppColors.textDim, fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deactivateIoT();
            },
            child: Text('Disconnect',
                style: GoogleFonts.poppins(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
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

  // severity: 'normal' | 'warning' | 'critical'
  Widget _buildSensorTile(String label, String value, IconData icon, String severity) {
    final Color tileColor = severity == 'critical'
        ? Colors.redAccent
        : severity == 'warning'
            ? Colors.orange
            : AppColors.primaryGreen;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: severity == 'critical'
            ? Colors.redAccent.withOpacity(0.07)
            : severity == 'warning'
                ? Colors.orange.withOpacity(0.07)
                : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: severity != 'normal' ? tileColor.withOpacity(0.4) : Colors.white10,
          width: severity != 'normal' ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: tileColor, size: 20),
          const SizedBox(height: 7),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.textMain,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 10),
          ),
          if (severity != 'normal') ...[
            const SizedBox(height: 4),
            Text(
              severity == 'critical' ? '⚠ CRITICAL' : '⚡ WARNING',
              style: GoogleFonts.poppins(
                color: tileColor,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              _sensorConnected ? "Live" : "--",
              style: GoogleFonts.poppins(
                color: AppColors.primaryGreen.withOpacity(0.7),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
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