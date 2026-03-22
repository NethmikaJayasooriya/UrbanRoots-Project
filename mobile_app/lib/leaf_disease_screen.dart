import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb check
import 'package:vibration/vibration.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'app_styles.dart';
import 'scan_history_screen.dart';
import 'disease_detail_screen.dart';
import 'services/api_service.dart';
import 'screens/dashboard/Marketplace/marketplace_api.dart';
import 'screens/dashboard/Marketplace/product_detail_screen.dart';
import 'screens/dashboard/Marketplace/marketplace_screen.dart' show Product, MarketplaceScreen1;

class LeafDiseaseAPI {
  static const String _baseUrl = 'https://nethmika89-urbanroots-ai.hf.space';

  static const List<String> _classNames = [
    "Blueberry___healthy",
    "Cherry_(including_sour)___Powdery_mildew",
    "Cherry_(including_sour)___healthy",
    "Crape_jasmine_Yellow_leaf_disease",
    "Crape_jasmine_healthy",
    "Crape_jasmine_insect_bite",
    "Dwarf_white_bauhinia_Death_leaf",
    "Dwarf_white_bauhinia_Yellow_Leaf_Disease",
    "Dwarf_white_bauhinia_healthy",
    "Grape___Black_rot",
    "Grape___Esca_(Black_Measles)",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",
    "Grape___healthy",
    "Hibiscus_Blight",
    "Hibiscus_Death_leaf",
    "Hibiscus_Scorch",
    "Hibiscus_healthy",
    "Night_flowering_jasmine_Early_blight",
    "Night_flowering_jasmine_Red_spot",
    "Night_flowering_jasmine_healthy",
    "Orange___Haunglongbing_(Citrus_greening)",
    "Pepper__bell___Bacterial_spot",
    "Pepper__bell___healthy",
    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___healthy",
    "Raspberry___healthy",
    "Rose___blight",
    "Rose___healthy",
    "Soybean___healthy",
    "Strawberry___Leaf_scorch",
    "Strawberry___healthy",
    "Tomato_Bacterial_spot",
    "Tomato_Early_blight",
    "Tomato_Late_blight",
    "Tomato_Leaf_Mold",
    "Tomato_Septoria_leaf_spot",
    "Tomato_Spider_mites_Two_spotted_spider_mite",
    "Tomato__Target_Spot",
    "Tomato__Tomato_YellowLeaf__Curl_Virus",
    "Tomato__Tomato_mosaic_virus",
    "Tomato_healthy",
  ];

  static Future<Map<String, dynamic>> predict(String imagePath) async {
    final uri     = Uri.parse('$_baseUrl/predict');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    final streamed = await request.send().timeout(
      const Duration(seconds: 30),
    );
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (data.containsKey('class_index')) {
        int idx = data['class_index'] as int;
        if (idx >= 0 && idx < _classNames.length) {
          data['disease'] = _classNames[idx];
        } else {
          data['disease'] = "Unknown Disease";
        }
      }
      
      if (!data.containsKey('disease')) {
        data['disease'] = 'Unknown Disease';
      }
      
      return data;
    } else {
      throw Exception('Server returned ${response.statusCode}');
    }
  }
}

Future<void> _vibrate(List<int> pattern) async {
  // Vibration is handled differently on web, so we guard it here
  if (kIsWeb) return; 
  final hasVibrator = await Vibration.hasVibrator() ?? false;
  if (!hasVibrator) return;
  Vibration.vibrate(pattern: pattern);
}

enum FlashOption { off, on, auto }

// Main leaf scanning interface that handles real-time camera preview and image processing.
class LeafScanScreen extends StatefulWidget {
  final bool isActive; 
  // Needed to handle navigation logic when this screen is nested inside an IndexedStack
  final VoidCallback? onBackPressed; 

  const LeafScanScreen({super.key, this.isActive = true, this.onBackPressed}); 

  @override
  State<LeafScanScreen> createState() => _LeafScanScreenState();
}

class _LeafScanScreenState extends State<LeafScanScreen>
    with TickerProviderStateMixin {
  CameraController?       _camController;
  List<CameraDescription> _cameras = [];
  int  _camIndex    = 0;
  bool _cameraReady = false;
  bool _analyzing   = false;
  bool _torchOn     = false; 
  FlashOption _flash = FlashOption.off;

  double _currentZoom   = 1.0;
  double _baseZoom      = 1.0;
  double _minZoom       = 1.0;
  double _maxZoom       = 8.0;
  bool   _showZoomBadge = false;

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;
  late Animation<double>   _glowAnim;  

  late AnimationController _rippleCtrl;
  late Animation<double>   _rippleAnim;

  late AnimationController _cornerCtrl;
  late Animation<double>   _cornerAnim;

  IconData get _flashIcon => switch (_flash) {
        FlashOption.off  => Icons.flash_off_rounded,
        FlashOption.on   => Icons.flash_on_rounded,
        FlashOption.auto => Icons.flash_auto_rounded,
      };

  Color get _flashColor => switch (_flash) {
        FlashOption.off  => Colors.white.withOpacity(0.6),
        FlashOption.on   => AppColors.neonGreen,
        FlashOption.auto => AppColors.warning,
      };

  String get _flashLabel => switch (_flash) {
        FlashOption.off  => 'Off',
        FlashOption.on   => 'On',
        FlashOption.auto => 'Auto',
      };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    
    if (widget.isActive) {
      _startCamera();
    }
  }

  @override
  void didUpdateWidget(LeafScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startCamera();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopCamera();
    }
  }

  void _initAnimations() {
    _pulseCtrl = AnimationController(vsync: this, duration: AppDuration.pulse)
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.93, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _glowAnim = Tween<double>(begin: 0.15, end: 0.55).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _rippleAnim = Tween<double>(begin: 1.0, end: 1.6).animate(
        CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));

    _cornerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _cornerAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _cornerCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rippleCtrl.dispose();
    _cornerCtrl.dispose();
    _camController?.setFlashMode(FlashMode.off);
    _camController?.dispose();
    super.dispose();
  }

  Future<void> _startCamera() async {
    // Check for camera permissions; web has its own flow via browser prompts
    if (kIsWeb) {
      try {
        _cameras = await availableCameras();
        if (_cameras.isEmpty) {
          _showCameraError('No cameras found on this device.');
          return;
        }
        await _initController(_camIndex);
      } catch (e) {
        debugPrint('Camera start error: $e');
        _showCameraError('Failed to start camera. Please try again.');
      }
      return;
    }

    final status = await Permission.camera.request();

    if (status.isGranted) {
      try {
        _cameras = await availableCameras();
        if (_cameras.isEmpty) {
          _showCameraError('No cameras found on this device.');
          return;
        }
        await _initController(_camIndex);
      } catch (e) {
        debugPrint('Camera start error: $e');
        _showCameraError('Failed to start camera. Please try again.');
      }
    } else if (status.isDenied) {
      _showCameraError(
          'Camera permission denied. Please allow camera access.');
    } else if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog();
    }
  }

  Future<void> _stopCamera() async {
    await _camController?.dispose();
    _camController = null;
    if (mounted) {
      setState(() {
        _cameraReady = false;
        _torchOn = false;
      });
    }
  }

  void _showCameraError(String message) {
    if (!mounted) return;
    setState(() => _cameraReady = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showPermissionSettingsDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadius.lgBR),
        title: Text('Camera Permission Required',
            style: AppText.subheading),
        content: Text(
          'Camera access was permanently denied. '
          'Please enable it in your device Settings to scan leaves.',
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Open Settings',
                style: TextStyle(color: AppColors.neonGreen)),
          ),
        ],
      ),
    );
  }

  Future<void> _initController(int index) async {
    try {
      final ctrl = CameraController(
        _cameras[index],
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await ctrl.initialize();
      if (!mounted) return;

      // Web might throw errors setting flash
      if (!kIsWeb) {
        await ctrl.setFlashMode(FlashMode.off);
      }

      final minZoom = await ctrl.getMinZoomLevel();
      final maxZoom = await ctrl.getMaxZoomLevel();

      await _camController?.dispose();
      setState(() {
        _camController = ctrl;
        _cameraReady   = true;
        _flash         = FlashOption.off;
        _torchOn       = false;
        _minZoom       = minZoom;
        _maxZoom       = maxZoom;
        _currentZoom   = minZoom;
        _baseZoom      = minZoom;
      });
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _cycleFlash() async {
    if (_camController == null || !_cameraReady || kIsWeb) return;
    final next =
        FlashOption.values[(_flash.index + 1) % FlashOption.values.length];
    setState(() => _flash = next);
    await _camController!.setFlashMode(FlashMode.off);
  }

  Future<void> _toggleTorch() async {
    if (_camController == null || !_cameraReady || kIsWeb) return;
    final next = !_torchOn;
    await _camController!.setFlashMode(
        next ? FlashMode.torch : FlashMode.off);
    setState(() => _torchOn = next);
  }

  Future<void> _setZoom(double zoom) async {
    if (_camController == null || !_cameraReady) return;
    final clamped = zoom.clamp(_minZoom, _maxZoom);
    await _camController!.setZoomLevel(clamped);
    setState(() => _currentZoom = clamped);
  }

  void _onScaleStart(ScaleStartDetails d) {
    _baseZoom = _currentZoom;
  }

  Future<void> _onScaleUpdate(ScaleUpdateDetails d) async {
    if (d.pointerCount < 2) return;
    await _setZoom(_baseZoom * d.scale);
    setState(() => _showZoomBadge = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showZoomBadge = false);
    });
  }

  Future<Map<String, dynamic>?> _callAPIAndSave(String imagePath) async {
    try {
      final result      = await LeafDiseaseAPI.predict(imagePath);
      final diseaseName = result['disease'] as String;
      
      num confRaw = result['confidence'] as num? ?? 0.0;
      final confidence  = confRaw > 1.0 ? confRaw.toDouble() / 100.0 : confRaw.toDouble();
      final isHealthy   = diseaseName.toLowerCase().contains('healthy');
      final severity    = _getSeverity(diseaseName);

      await ScanHistoryService.saveScan(ScanRecord(
        id:          DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath:   imagePath,
        diseaseName: diseaseName,
        confidence:  confidence,
        severity:    severity,
        scannedAt:   DateTime.now(),
        isHealthy:   isHealthy,
      ));
      return result;
    } catch (e) {
      debugPrint('API error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service temporarily unavailable'),
            backgroundColor: AppColors.danger,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return null;
    }
  }

  String _getSeverity(String diseaseName) {
    final n = diseaseName.toLowerCase();
    if (n.contains('healthy'))                      return 'Low';
    if (n.contains('virus') || n.contains('curl'))  return 'High';
    if (n.contains('blight') || n.contains('mold')) return 'High';
    if (n.contains('spot') || n.contains('mites'))  return 'Medium';
    return 'Medium';
  }

  Future<void> _pickFromGallery() async {
    try {
      // Platform check guards against calling native Android permissions on Web platform
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          _showCameraError('Gallery permission denied. Please allow access in Settings.');
          return;
        }
      }

      final picker  = ImagePicker();
      final XFile? picked = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 100);
      if (picked == null || !mounted) return;

      setState(() => _analyzing = true);

      final result = await _callAPIAndSave(picked.path);
      if (result == null) return;

      await _vibrate([0, 80, 150, 80]);

      if (!mounted) return;
      Navigator.push(
        context,
        _slideRoute(DiseaseResultScreen(
          imagePath:   picked.path,
          diseaseName: result['disease'] as String,
          confidence:  (result['confidence'] as num).toDouble(),
        )),
      );
    } catch (e) {
      debugPrint('Gallery error: $e');
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<void> _capture() async {
    if (!_cameraReady || _camController == null || _analyzing) return;

    _rippleCtrl.forward(from: 0);
    setState(() => _analyzing = true);

    XFile? photo;
    try {
      if (!kIsWeb) {
        try {
          await _camController!.setFocusMode(FocusMode.auto);
          await _camController!.setExposureMode(ExposureMode.auto);
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (_) {}

        if (_flash == FlashOption.on) {
          await _camController!.setFlashMode(FlashMode.torch);
        } else if (_flash == FlashOption.auto) {
          await _camController!.setFlashMode(FlashMode.torch);
        }
        if (_flash != FlashOption.off) {
          await Future.delayed(const Duration(milliseconds: 150));
        }
      }

      photo = await _camController!.takePicture();
      if (!kIsWeb) await _camController!.setFlashMode(FlashMode.off);

      final result = await _callAPIAndSave(photo.path);
      if (result == null) return;
      
      await _vibrate([0, 80, 150, 80]);

      if (!mounted) return;
      Navigator.push(
          context,
          _slideRoute(DiseaseResultScreen(
            imagePath:   photo.path,
            diseaseName: result['disease'] as String,
            confidence:  (result['confidence'] as num).toDouble(),
          )));
    } catch (e) {
      debugPrint('Capture error: $e');
    } finally {
      if (!kIsWeb) {
        try {
          await _camController?.setFlashMode(FlashMode.off);
        } catch (_) {}
      }
      if (mounted) setState(() {
        _analyzing = false;
        _torchOn   = false; 
      });
    }
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder:        (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 420),
      transitionsBuilder: (_, a, __, child) => SlideTransition(
        position: Tween<Offset>(
                begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return Container(color: AppColors.bgColor);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      resizeToAvoidBottomInset: false, 
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          _buildVignette(),
          Positioned(
              top: 0, left: 0, right: 0, height: 160,
              child: Container(decoration: AppStyles.topGradient)),
          Positioned(
              bottom: 0, left: 0, right: 0, height: 210,
              child: Container(decoration: AppStyles.bottomGradient)),
          _buildTopBar(),
          _buildScanFrame(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_cameraReady || _camController == null) {
      return Container(
        color: AppColors.bgColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32, height: 32,
                child: CircularProgressIndicator(
                    color: AppColors.neonGreen, strokeWidth: 2),
              ),
              const SizedBox(height: 14),
              Text('Starting camera...', style: AppText.caption),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _startCamera,
                child: Text('Tap to retry',
                    style: TextStyle(color: AppColors.neonGreen)),
              ),
            ],
          ),
        ),
      );
    }
    return AnimatedOpacity(
      opacity:  _cameraReady ? 1.0 : 0.0,
      duration: AppDuration.normal,
      child: GestureDetector(
        onScaleStart:  _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width:  _camController!.value.previewSize!.height,
                  height: _camController!.value.previewSize!.width,
                  child:  CameraPreview(_camController!),
                ),
              ),
            ),
            Positioned(
              top: 100, left: 0, right: 0,
              child: AnimatedOpacity(
                opacity:  _showZoomBadge ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color:        Colors.black.withOpacity(0.55),
                      borderRadius: AppRadius.pillBR,
                      border: Border.all(
                          color: AppColors.neonGreen.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in_rounded,
                            color: AppColors.neonGreen, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_currentZoom.toStringAsFixed(1)}x',
                          style: TextStyle(
                            color:      AppColors.neonGreen,
                            fontSize:   14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVignette() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top:    statusBarHeight + 8,
          left:   14,
          right:  14,
          bottom: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _iconBtn(
              icon:  Icons.arrow_back_ios_new_rounded,
              // Update: Use the callback to return to the home tab if provided
              onTap: () {
                if (widget.onBackPressed != null) {
                  widget.onBackPressed!(); 
                } else {
                  Navigator.maybePop(context);
                }
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color:        AppColors.overlay(0.5),
                borderRadius: AppRadius.pillBR,
                border: Border.all(
                    color: Colors.white.withOpacity(0.1), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco_rounded,
                      color: AppColors.neonGreen, size: 15),
                  const SizedBox(width: 6),
                  Text('Leaf Scanner', style: AppText.title),
                ],
              ),
            ),
            GestureDetector(
              onTap: _cycleFlash,
              child: AnimatedContainer(
                duration: AppDuration.fast,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:        AppColors.overlay(0.5),
                  borderRadius: AppRadius.pillBR,
                  border: Border.all(
                      color: _flashColor.withOpacity(0.6), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_flashIcon, color: _flashColor, size: 17),
                    const SizedBox(width: 5),
                    Text(_flashLabel,
                        style: TextStyle(
                          color:      _flashColor,
                          fontSize:   12,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanFrame() {
    const frameSize = 270.0;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: frameSize, height: frameSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.lgBR,
                      color: Colors.black.withOpacity(0.08),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _cornerAnim,
                  builder: (_, __) => Stack(children: [
                    _corner(top: -1,    left: -1,  opacity: _cornerAnim.value),
                    _corner(top: -1,    right: -1, opacity: _cornerAnim.value),
                    _corner(bottom: -1, left: -1,  opacity: _cornerAnim.value),
                    _corner(bottom: -1, right: -1, opacity: _cornerAnim.value),
                  ]),
                ),
                AnimatedBuilder(
                  animation: _rippleAnim,
                  builder: (_, __) {
                    if (!_rippleCtrl.isAnimating) return const SizedBox();
                    final opacity =
                        (1.0 - (_rippleAnim.value - 1.0) / 0.6).clamp(0.0, 1.0);
                    return Positioned.fill(
                      child: Transform.scale(
                        scale: _rippleAnim.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.lgBR,
                            border: Border.all(
                              color: AppColors.neonGreen.withOpacity(opacity),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _rippleAnim,
                  builder: (_, __) {
                    if (!_rippleCtrl.isAnimating) return const SizedBox();
                    final scale =
                        (_rippleAnim.value - 0.1).clamp(1.0, 1.6);
                    final opacity =
                        (0.6 - (_rippleAnim.value - 1.0) / 0.6).clamp(0.0, 1.0);
                    return Positioned.fill(
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.lgBR,
                            border: Border.all(
                              color: AppColors.neonGreen.withOpacity(opacity),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (_analyzing) _ScanLine(frameSize: frameSize),
                if (!_analyzing)
                  Center(
                    child: Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.neonGreen.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 4, height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neonGreen.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: AppDuration.fast,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 0.3), end: Offset.zero)
                    .animate(anim),
                child: child,
              ),
            ),
            child: _analyzing
                ? _statusPill(
                    key:         const ValueKey('analyzing'),
                    icon:        null,
                    text:        'Analyzing Tissue...',
                    color:       AppColors.neonGreen,
                    showSpinner: true,
                  )
                : _statusPill(
                    key:   const ValueKey('hint'),
                    icon:  Icons.center_focus_strong_rounded,
                    text:  'Center the leaf in the frame',
                    color: Colors.white.withOpacity(0.6),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_analyzing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tipChip(Icons.wb_sunny_outlined,          'Good light'),
                      const SizedBox(width: 8),
                      _tipChip(Icons.straighten_rounded,         '10–15 cm'),
                      const SizedBox(width: 8),
                      _tipChip(Icons.motion_photos_off_outlined, 'Hold still'),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment:  MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _labeledIconBtn(
                    icon:    Icons.photo_library_rounded,
                    label:   'Gallery',
                    onTap:   _analyzing ? null : _pickFromGallery,
                    enabled: !_analyzing,
                  ),
                  const SizedBox(width: 32),
                  _buildShutterButton(),
                  const SizedBox(width: 32),
                  _labeledIconBtn(
                    icon:    _torchOn
                        ? Icons.flashlight_on_rounded
                        : Icons.flashlight_off_rounded,
                    label:   'Light',
                    onTap:   _analyzing ? null : _toggleTorch,
                    enabled: !_analyzing,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: () async {
        await _vibrate([0, 60]);
        _capture();
      },
      child: _analyzing
          ? Container(
              width: 84, height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.neonGreen.withOpacity(0.5), width: 3),
                color: AppColors.overlay(0.3),
              ),
              child: Center(
                child: SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(
                      color: AppColors.neonGreen, strokeWidth: 2.5),
                ),
              ),
            )
          : AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, child) => ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 84, height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neonGreen, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color:        AppColors.neonGreen.withOpacity(
                            _glowAnim.value),
                        blurRadius:   28,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color:        AppColors.neonGreen.withOpacity(
                            _glowAnim.value * 0.5),
                        blurRadius:   50,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 62, height: 62,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonGreen,
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.black, size: 28),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _iconBtn({
    required IconData     icon,
    required VoidCallback onTap,
    double size = 46,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: AppStyles.iconCircle,
        child: Icon(icon, color: Colors.white, size: size * 0.42),
      ),
    );
  }

  Widget _labeledIconBtn({
    required IconData      icon,
    required String        label,
    required VoidCallback? onTap,
    required bool          enabled,
    Animation<double>?     rotateAnim,
    double size = 52,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity:  enabled ? 1.0 : 0.35,
        duration: AppDuration.fast,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size, height: size,
              decoration: AppStyles.iconCircle,
              child: rotateAnim != null
                  ? AnimatedBuilder(
                      animation: rotateAnim,
                      builder: (_, child) => Transform.rotate(
                        angle: rotateAnim.value * 3.14159,
                        child: child,
                      ),
                      child: Icon(icon,
                          color: Colors.white, size: size * 0.42),
                    )
                  : Icon(icon, color: Colors.white, size: size * 0.42),
            ),
            const SizedBox(height: 6),
            Text(label, style: AppText.tip),
          ],
        ),
      ),
    );
  }

  Widget _corner({
    double? top, double? bottom, double? left, double? right,
    double opacity = 1.0,
  }) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: 30, height: 30,
          child: CustomPaint(
            painter: _CornerPainter(
              drawTop:    top    != null,
              drawBottom: bottom != null,
              drawLeft:   left   != null,
              drawRight:  right  != null,
              color:     AppColors.neonGreen,
              thickness: 3.0,
              radius:    7.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusPill({
    required Key    key,
    required String text,
    required Color  color,
    IconData?       icon,
    bool            showSpinner = false,
  }) {
    return Container(
      key:     key,
      padding: AppSpacing.pillPadding,
      decoration: BoxDecoration(
        color:        AppColors.overlay(0.55),
        borderRadius: AppRadius.pillBR,
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner)
            SizedBox(
              width: 13, height: 13,
              child: CircularProgressIndicator(color: color, strokeWidth: 2),
            )
          else if (icon != null)
            Icon(icon, color: color, size: 15),
          const SizedBox(width: 7),
          Text(text,
              style: TextStyle(
                color:      color,
                fontSize:   13,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _tipChip(IconData icon, String label) {
    return Container(
      padding: AppSpacing.chipPadding,
      decoration: AppStyles.tipChip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.54), size: 12),
          const SizedBox(width: 4),
          Text(label, style: AppText.tip),
        ],
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  final double frameSize;
  const _ScanLine({required this.frameSize});

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppDuration.scan)
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top:   _anim.value * (widget.frameSize - 4),
        left:  0,
        right: 0,
        child: Container(height: 2.5, decoration: AppStyles.scanLine),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool   drawTop, drawBottom, drawLeft, drawRight;
  final Color  color;
  final double thickness, radius;

  const _CornerPainter({
    required this.drawTop,   required this.drawBottom,
    required this.drawLeft,  required this.drawRight,
    required this.color,     required this.thickness,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color       = color
      ..strokeWidth = thickness
      ..strokeCap   = StrokeCap.round
      ..style       = PaintingStyle.stroke;

    final w = size.width, h = size.height, len = w - radius;

    if (drawTop && drawLeft) {
      canvas.drawLine(Offset(radius, 0), Offset(len, 0), p);
      canvas.drawLine(Offset(0, radius), Offset(0, len), p);
      canvas.drawArc(Rect.fromLTWH(0, 0, radius * 2, radius * 2),
          3.14159, 3.14159 / 2, false, p);
    }
    if (drawTop && drawRight) {
      canvas.drawLine(Offset(0, 0), Offset(len - radius, 0), p);
      canvas.drawLine(Offset(w, radius), Offset(w, len), p);
      canvas.drawArc(
          Rect.fromLTWH(w - radius * 2, 0, radius * 2, radius * 2),
          -3.14159 / 2, 3.14159 / 2, false, p);
    }
    if (drawBottom && drawLeft) {
      canvas.drawLine(Offset(radius, h), Offset(len, h), p);
      canvas.drawLine(Offset(0, 0), Offset(0, h - radius), p);
      canvas.drawArc(
          Rect.fromLTWH(0, h - radius * 2, radius * 2, radius * 2),
          3.14159 / 2, 3.14159 / 2, false, p);
    }
    if (drawBottom && drawRight) {
      canvas.drawLine(Offset(0, h), Offset(len - radius, h), p);
      canvas.drawLine(Offset(w, 0), Offset(w, h - radius), p);
      canvas.drawArc(
          Rect.fromLTWH(
              w - radius * 2, h - radius * 2, radius * 2, radius * 2),
          0, 3.14159 / 2, false, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ═══════════════════════════════════════════════
// SCREEN 2 — Disease Result Screen
// (This section remains unchanged from your previous correct code)
// ═══════════════════════════════════════════════
class DiseaseResultScreen extends StatefulWidget {
  final String imagePath;
  final String diseaseName;
  final double confidence;

  const DiseaseResultScreen({
    super.key,
    required this.imagePath,
    this.diseaseName = 'Unknown',
    this.confidence  = 0.0,
  });

  @override
  State<DiseaseResultScreen> createState() => _DiseaseResultScreenState();
}

class _DiseaseResultScreenState extends State<DiseaseResultScreen>
    with SingleTickerProviderStateMixin {
  final Map<int, bool> _checked = {};
  final GlobalKey  _resultKey = GlobalKey(); 
  late AnimationController _barCtrl;
  late Animation<double>   _barAnim;
  Future<String?>? _treatmentFuture;

  @override
  void initState() {
    super.initState();
    _treatmentFuture = ApiService.fetchDiseaseTreatment(widget.diseaseName);
    _barCtrl =
        AnimationController(vsync: this, duration: AppDuration.bar)..forward();
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context:       context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        decoration: BoxDecoration(
          color:        AppColors.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
              color: AppColors.neonGreen.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color:        Colors.white.withOpacity(0.2),
                  borderRadius: AppRadius.pillBR,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Share Scan Result', style: AppText.subheading),
            const SizedBox(height: 6),
            Text('Choose how to share your result',
                style: AppText.caption),
            const SizedBox(height: 20),

            _shareOptionTile(
              icon:     Icons.text_fields_rounded,
              color:    AppColors.neonGreen,
              title:    'Share as Text',
              subtitle: 'Send via WhatsApp, SMS, Email...',
              onTap: () {
                Navigator.pop(context);
                _shareAsText();
              },
            ),
            const SizedBox(height: 12),

            _shareOptionTile(
              icon:     Icons.image_rounded,
              color:    const Color(0xFF69B4FF),
              title:    'Share as Image',
              subtitle: 'Capture result card and share',
              onTap: () {
                Navigator.pop(context);
                _shareAsImage();
              },
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: TextStyle(color: Colors.white38)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareOptionTile({
    required IconData     icon,
    required Color        color,
    required String       title,
    required String       subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: AppStyles.card,
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.12),
                borderRadius: AppRadius.smBR,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,   style: AppText.subheading.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.caption),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatDiseaseName(String raw) {
    if (raw.trim().toLowerCase().contains('not recognized')) return 'Unrecognized Object';
    
    String cleanName = raw;
    if (cleanName.contains('___')) {
      final parts = cleanName.split('___');
      final crop = parts[0].replaceAll('_', ' ').trim();
      final condition = parts[1].replaceAll('_', ' ').trim();
      
      if (condition.toLowerCase() == 'healthy') {
        cleanName = 'Healthy $crop';
      } else {
        String c = condition;
        if (c.toLowerCase().contains(crop.toLowerCase())) {
          c = c.replaceAll(RegExp(crop, caseSensitive: false), '').trim();
        }
        cleanName = '$crop $c'.trim();
      }
    }
    
    cleanName = cleanName.replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleanName.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _shareAsText() {
    final confidenceStr = '${widget.confidence.toStringAsFixed(1)}%';
    final text = '''
🌿 UrbanRoots — Scan Result

🦠 Disease: ${_formatDiseaseName(widget.diseaseName)}
📊 Confidence: $confidenceStr

Scanned with UrbanRoots 🌱
''';
    Share.share(text.trim(), subject: 'Leaf Scan Result — ${_formatDiseaseName(widget.diseaseName)}');
  }

  Future<void> _shareAsImage() async {
    try {
      final boundary = _resultKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/scan_result.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:    'My leaf scan result from UrbanRoots 🌿',
        subject: 'Leaf Scan Result',
      );
    } catch (e) {
      debugPrint('Share image error: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      resizeToAvoidBottomInset: false, 
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(widget.imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.bgColor),
          ),
          Container(color: AppColors.overlay(0.35)),
          Positioned(
              top: 0, left: 0, right: 0, height: 150,
              child: Container(decoration: AppStyles.topGradient)),

          Positioned(
            top:   0,
            left:  0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top:    MediaQuery.of(context).padding.top + 8,
                left:   14,
                right:  14,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: AppStyles.iconCircle,
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color:        AppColors.overlay(0.5),
                      borderRadius: AppRadius.pillBR,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco_rounded,
                            color: AppColors.neonGreen, size: 14),
                        const SizedBox(width: 6),
                        Text('Scan Result', style: AppText.title),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: _showShareOptions,
                    child: Container(
                      width: 42, height: 42,
                      decoration: AppStyles.iconCircle,
                      child: const Icon(Icons.share_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.62,
            minChildSize:     0.48,
            maxChildSize:     0.94,
            builder: (_, sc) => Container(
              decoration: AppStyles.bottomSheet,
              child: RepaintBoundary(
                key: _resultKey,
                child: SingleChildScrollView(
                controller: sc,
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: AppRadius.pillBR,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: widget.diseaseName.trim().toLowerCase().contains('not recognized')
                          ? BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: AppRadius.pillBR,
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            )
                          : widget.diseaseName.trim().toLowerCase().contains('healthy')
                              ? BoxDecoration(
                                  color: AppColors.neonGreen.withOpacity(0.15),
                                  borderRadius: AppRadius.pillBR,
                                  border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
                                )
                              : AppStyles.dangerBadge,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.diseaseName.trim().toLowerCase().contains('not recognized')
                                ? Icons.question_mark_rounded
                                : widget.diseaseName.trim().toLowerCase().contains('healthy')
                                    ? Icons.check_circle_rounded
                                    : Icons.warning_amber_rounded,
                            color: widget.diseaseName.trim().toLowerCase().contains('not recognized')
                                ? Colors.white54
                                : widget.diseaseName.trim().toLowerCase().contains('healthy')
                                    ? AppColors.neonGreen
                                    : AppColors.danger,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.diseaseName.trim().toLowerCase().contains('not recognized')
                                ? 'Unrecognized Object'
                                : widget.diseaseName.trim().toLowerCase().contains('healthy')
                                    ? 'Healthy Leaf'
                                    : 'Disease Detected',
                            style: TextStyle(
                              color: widget.diseaseName.trim().toLowerCase().contains('not recognized')
                                  ? Colors.white54
                                  : widget.diseaseName.trim().toLowerCase().contains('healthy')
                                      ? AppColors.neonGreen
                                      : AppColors.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiseaseDetailScreen(
                              diseaseName: widget.diseaseName),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(_formatDiseaseName(widget.diseaseName),
                                style: AppText.heading),
                          ),
                          const SizedBox(width: 8),
                          AnimatedGlowingDetailsButton(
                            text: 'Details',
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AI Confidence', style: AppText.label),
                        Text('${widget.confidence.toStringAsFixed(1)}%', style: AppText.primaryValue),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _barAnim,
                      builder: (_, __) => ClipRRect(
                        borderRadius: AppRadius.pillBR,
                        child: LinearProgressIndicator(
                          value:           _barAnim.value * (widget.confidence / 100.0),
                          minHeight:       8,
                          backgroundColor: Colors.white.withOpacity(0.07),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.neonGreen),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Divider(color: Colors.white.withOpacity(0.07)),
                    const SizedBox(height: AppSpacing.lg),
                    if (widget.diseaseName.trim().toLowerCase().contains('not recognized')) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.psychology_alt_rounded, size: 48, color: Colors.white24),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "That doesn't look like a leaf!",
                                style: AppText.subheading.copyWith(color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Our AI couldn't classify this image. Please make sure the leaf is clearly visible, well-lit, and in focus.",
                                style: AppText.caption.copyWith(color: Colors.white54, height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ] else if (widget.diseaseName.trim().toLowerCase().contains('healthy')) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.neonGreen.withOpacity(0.1)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.neonGreen.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified_rounded, size: 48, color: AppColors.neonGreen),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Your plant is perfectly healthy! 🌱",
                                style: AppText.subheading.copyWith(color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "We couldn't detect any visible signs of disease or infection. Keep up your excellent watering and care routine, your plant is doing amazing!",
                                style: AppText.caption.copyWith(color: Colors.white54, height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Text('Recommended Treatment Plan',
                          style: AppText.subheading),
                    const SizedBox(height: 12),
                    FutureBuilder<String?>(
                      future: _treatmentFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const GlowingLeafLoading();
                        }
                        
                        List<String> plans = [
                          'Isolate the plant to prevent spread',
                          'Remove and destroy all affected leaves',
                          'Apply organic neem oil solution weekly',
                        ];

                        if (snapshot.hasData && snapshot.data != null) {
                          var parsedLines = snapshot.data!
                              .split('\n')
                              .map((l) => l.replaceAll('**', '').replaceAll('*', '').replaceAll('"', ''))
                              .map((l) => l.replaceAll(RegExp(r'^[\-\d\.\s]+'), '').trim())
                              .where((l) => l.isNotEmpty && l.length > 5)
                              .take(5)
                              .toList();
                              
                          if (parsedLines.isNotEmpty) {
                            plans = parsedLines;
                          } else {
                            plans = [snapshot.data!.replaceAll('**', '').replaceAll('*', '').replaceAll('"', '').trim()];
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: plans.asMap().entries.map((e) => _buildTreatmentCard(e.key, e.value)).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    MarketplaceRemedyScroller(diseaseName: widget.diseaseName),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedScanAgainButton(
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MarketplaceScreen1()),
                              );
                            },
                            icon: const Icon(Icons.shopping_bag_rounded,
                                size: 18, color: Colors.black),
                            label: const Text('Buy Remedy',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w800)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor: AppColors.neonGreen.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
              ), 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(int index, String text) {
    final isChecked = _checked[index] ?? false;
    final iconList = [
      Icons.shield_outlined,
      Icons.content_cut_rounded,
      Icons.water_drop_outlined,
      Icons.medical_services_outlined,
    ];
    final stepIcon = iconList[index % iconList.length];

    return TweenAnimationBuilder<double>(
      key: ValueKey(text.hashCode ^ index),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => setState(() => _checked[index] = !isChecked),
        child: AnimatedContainer(
          duration: AppDuration.normal,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isChecked
                ? AppColors.neonGreen.withOpacity(0.1)
                : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked
                ? AppColors.neonGreen.withOpacity(0.5)
                : Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: isChecked
              ? [
                  BoxShadow(
                    color: AppColors.neonGreen.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isChecked 
                  ? AppColors.neonGreen.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isChecked ? Icons.check_circle_rounded : stepIcon,
                color: isChecked ? AppColors.neonGreen : Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STEP ${index + 1}',
                    style: TextStyle(
                      color: isChecked ? AppColors.neonGreen : AppColors.neonGreen.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body.copyWith(
                      color: isChecked ? Colors.white : Colors.white.withOpacity(0.8),
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class GlowingLeafLoading extends StatefulWidget {
  const GlowingLeafLoading({super.key});
  @override
  State<GlowingLeafLoading> createState() => _GlowingLeafLoadingState();
}

class _GlowingLeafLoadingState extends State<GlowingLeafLoading> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreen.withOpacity(0.1 + (math.sin(_ctrl.value * math.pi) * 0.2)),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ]
                  ),
                  child: CustomPaint(
                    painter: LeafEdgePainter(progress: _progress.value),
                    size: const Size(80, 80),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                final pulse = (math.sin(_ctrl.value * 2 * math.pi) + 1) / 2;
                return Text(
                  'Synthesizing Treatment...',
                  style: TextStyle(
                    color: AppColors.neonGreen.withOpacity(0.5 + (pulse * 0.5)),
                    fontSize: 12,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700
                  )
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedScanAgainButton extends StatefulWidget {
  final VoidCallback onPressed;
  const AnimatedScanAgainButton({super.key, required this.onPressed});

  @override
  State<AnimatedScanAgainButton> createState() => _AnimatedScanAgainButtonState();
}

class _AnimatedScanAgainButtonState extends State<AnimatedScanAgainButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withOpacity(0.05),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 4.0, 
                      child: Transform.rotate(
                        angle: _ctrl.value * 2 * math.pi,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                AppColors.neonGreen.withOpacity(0.4),
                                Colors.white,
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.7, 0.9, 0.95, 1.0],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(1.5), 
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor ?? const Color(0xff121212),
                      borderRadius: BorderRadius.circular(14.5), 
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.neonGreen),
                    SizedBox(width: 8),
                    Text('Scan Again', 
                      style: TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 13,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w800
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeafEdgePainter extends CustomPainter {
  final double progress;
  LeafEdgePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.95); 
    
    path.cubicTo(
      size.width * 0.0, size.height * 0.8,
      size.width * 0.1, size.height * 0.2,
      size.width * 0.5, size.height * 0.05 
    );
    
    path.cubicTo(
      size.width * 0.9, size.height * 0.2,
      size.width * 1.0, size.height * 0.8,
      size.width * 0.5, size.height * 0.95 
    );

    final bgPaint = Paint()
      ..color = AppColors.neonGreen.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, bgPaint);

    final paint = Paint()
      ..color = AppColors.neonGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0); 

    final metrics = path.computeMetrics().toList();
    for (var metric in metrics) {
      final drawLength = metric.length * progress;
      final extractPath = metric.extractPath(0.0, drawLength);
      canvas.drawPath(extractPath, paint);
      
      if (progress > 0.0 && progress < 1.0) {
        final tangent = metric.getTangentForOffset(drawLength);
        if (tangent != null) {
          final cometPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
          canvas.drawCircle(tangent.position, 6.0, cometPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LeafEdgePainter oldDelegate) => oldDelegate.progress != progress;
}

class AnimatedGlowingDetailsButton extends StatefulWidget {
  final String text;
  final bool isPrimary;

  const AnimatedGlowingDetailsButton({
    super.key,
    required this.text,
    this.isPrimary = true,
  });

  @override
  State<AnimatedGlowingDetailsButton> createState() => _AnimatedGlowingDetailsButtonState();
}

class _AnimatedGlowingDetailsButtonState extends State<AnimatedGlowingDetailsButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final glowOpacity = 0.4 + (_ctrl.value * 0.4); 
        
        if (widget.isPrimary) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.neonGreen,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreen.withOpacity(glowOpacity),
                  blurRadius: 6 + (_ctrl.value * 8),
                  spreadRadius: 1 + (_ctrl.value * 3),
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.black),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.1 + (_ctrl.value * 0.1)),
              borderRadius: AppRadius.pillBR,
              border: Border.all(
                  color: AppColors.neonGreen.withOpacity(0.3 + (_ctrl.value * 0.5))),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreen.withOpacity(glowOpacity * 0.3),
                  blurRadius: 4 + (_ctrl.value * 6),
                  spreadRadius: _ctrl.value * 2,
                )
              ]
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.text,
                    style: TextStyle(
                      color:      AppColors.neonGreen,
                      fontSize:   11,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(width: 3),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.neonGreen, size: 10),
              ],
            ),
          );
        }
      },
    );
  }
}

// Handles the bottom scroller that shows real products from the marketplace matching the diagnosis.
class MarketplaceRemedyScroller extends StatefulWidget {
  final String diseaseName;
  const MarketplaceRemedyScroller({super.key, required this.diseaseName});

  @override
  State<MarketplaceRemedyScroller> createState() => _MarketplaceRemedyScrollerState();
}

class _MarketplaceRemedyScrollerState extends State<MarketplaceRemedyScroller> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchAndFilterRemedies();
  }

  Future<List<Product>> _fetchAndFilterRemedies() async {
    try {
      // Fetch the full product inventory from the backend
      final jsonList = await MarketplaceApi.fetchProducts();
      final allProducts = jsonList.map((p) => Product(
        id: p['id'].toString(),
        name: p['name'],
        category: p['category'],
        price: double.tryParse(p['price']?.toString() ?? '0') ?? 0.0,
        description: p['description'],
        imageUrl: p['imageUrl'] ?? p['image_url'],
      )).toList();

      // Get the list of recommended remedies for this specific disease from our local database
      final remedies = getRemediesForDisease(widget.diseaseName);
      if (remedies.isEmpty) return [];

      // Match the recommended names against actual marketplace inventory to find buyable products
      List<Product> matched = [];
      for (var remedy in remedies) {
        final nameLower = remedy.name.toLowerCase();
        final match = allProducts.firstWhere(
          (p) => p.name.toLowerCase() == nameLower,
          orElse: () => const Product(id: 'null', name: '', description: '', price: 0, category: ''),
        );
        if (match.id != 'null') {
          matched.add(match);
        }
      }

      return matched.take(3).toList();
    } catch (e) {
      debugPrint('Error in _fetchAndFilterRemedies: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: AppColors.neonGreen, strokeWidth: 2),
              ),
            ),
          );
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const SizedBox.shrink(); 
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Purchase Remedies', style: AppText.subheading),
                Icon(Icons.arrow_forward_rounded, color: Colors.white38, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final p = products[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: p),
                      ),
                    ),
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.all(12),
                      decoration: AppStyles.card,
                      child: Row(
                        children: [
                          Container(
                            width: 55, height: 55,
                            decoration: AppStyles.productIcon,
                            child: CategoryIconWidget(category: p.category),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  p.name,
                                  style: AppText.subheading.copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      'Rs. ${p.price.toStringAsFixed(2)}',
                                      style: AppText.primaryValue.copyWith(
                                        fontSize: 13,
                                        color: AppColors.neonGreen,
                                      ),
                                    ),
                                    const Spacer(),
                                    const AnimatedGlowingDetailsButton(text: 'view', isPrimary: true),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class CategoryIconWidget extends StatelessWidget {
  final String category;
  const CategoryIconWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (category) {
      case 'Seeds': icon = Icons.spa_rounded; break;
      case 'Indoor': icon = Icons.local_florist_rounded; break;
      case 'Leafy Greens': icon = Icons.grass_rounded; break;
      case 'Tools': icon = Icons.hardware_rounded; break;
      case 'treatment': icon = Icons.science_rounded; break; // Custom for our seeded products
      default: icon = Icons.eco_rounded;
    }
    return Icon(icon, color: AppColors.neonGreen, size: 24);
  }
}
