import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// Update: Added foundation for kIsWeb check
import 'package:flutter/foundation.dart'; 
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

class LeafDiseaseAPI {
  static const String _baseUrl = 'http://192.168.1.6:8000';

  static Future<Map<String, dynamic>> predict(String imagePath) async {
    final uri     = Uri.parse('$_baseUrl/predict');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    final streamed = await request.send().timeout(
      const Duration(seconds: 30),
    );
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Server returned ${response.statusCode}');
    }
  }
}

Future<void> _vibrate(List<int> pattern) async {
  // Update: Safely handle vibration on web
  if (kIsWeb) return; 
  final hasVibrator = await Vibration.hasVibrator() ?? false;
  if (!hasVibrator) return;
  Vibration.vibrate(pattern: pattern);
}

enum FlashOption { off, on, auto }

// ═══════════════════════════════════════════════
// SCREEN 1 — Leaf Scan Screen
// ═══════════════════════════════════════════════
class LeafScanScreen extends StatefulWidget {
  final bool isActive; 
  // Update: Callback for handling navigation inside IndexedStack
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
    // Update: Safely handle permissions for Web platform
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

  Future<Map<String, dynamic>> _callAPIAndSave(String imagePath) async {
    try {
      final result      = await LeafDiseaseAPI.predict(imagePath);
      final diseaseName = result['disease'] as String;
      final confidence  = (result['confidence'] as num).toDouble() / 100.0;
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
      await ScanHistoryService.saveScan(ScanRecord(
        id:          DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath:   imagePath,
        diseaseName: 'API Error — Check connection',
        confidence:  0.0,
        severity:    'Low',
        scannedAt:   DateTime.now(),
        isHealthy:   false,
      ));
      return {'disease': 'API Error — Check connection', 'confidence': 0.0};
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
      // Update: Guarded Platform._operatingSystem error for Web
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
          padding: const EdgeInsets.only(bottom: 30),
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
  final List<bool> _checked  = [false, false, false];
  final GlobalKey  _resultKey = GlobalKey(); 
  late AnimationController _barCtrl;
  late Animation<double>   _barAnim;

  @override
  void initState() {
    super.initState();
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

  void _shareAsText() {
    final confidenceStr = '${widget.confidence.toStringAsFixed(1)}%';
    final text = '''
🌿 UrbanRoots — Scan Result

🦠 Disease: ${widget.diseaseName}
📊 Confidence: $confidenceStr

Scanned with UrbanRoots 🌱
''';
    Share.share(text.trim(), subject: 'Leaf Scan Result — ${widget.diseaseName}');
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: AppStyles.dangerBadge,
                      
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 14),
                          SizedBox(width: 6),
                          Text('Disease Detected',
                              style: TextStyle(
                                color:      AppColors.danger,
                                fontSize:   11,
                                fontWeight: FontWeight.w700,
                              )),
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
                            child: Text(widget.diseaseName,
                                style: AppText.heading),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neonGreen.withOpacity(0.1),
                              borderRadius: AppRadius.pillBR,
                              border: Border.all(
                                  color: AppColors.neonGreen.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Details',
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
                    Text('Recommended Treatment Plan',
                        style: AppText.subheading),
                    const SizedBox(height: 12),
                    ...[
                      'Isolate the plant to prevent spread',
                      'Remove and destroy all affected leaves',
                      'Apply organic neem oil solution weekly',
                    ].asMap().entries.map((e) => _checkItem(e.key, e.value)),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: AppSpacing.cardPadding,
                      decoration: AppStyles.card,
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: AppStyles.productIcon,
                            child: const Icon(Icons.eco_rounded,
                                color: AppColors.accent, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Organic Neem Oil',
                                    style: AppText.subheading
                                        .copyWith(fontSize: 15)),
                                const SizedBox(height: 3),
                                Text('Natural & Effective',
                                    style: AppText.caption),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: AppStyles.viewButton,
                              child: Text('View',
                                  style: TextStyle(
                                    color:      AppColors.neonGreen,
                                    fontSize:   12,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.refresh_rounded,
                                size: 18, color: AppColors.neonGreen),
                            label: Text('Scan Again',
                                style: TextStyle(
                                    color:      AppColors.neonGreen,
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              padding: AppSpacing.buttonPadding,
                              side: BorderSide(
                                  color:
                                      AppColors.neonGreen.withOpacity(0.4)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.xxlBR),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.shopping_cart_rounded,
                                size: 18, color: Colors.black),
                            label: Text('Buy Remedy',
                                style: AppText.buttonLabel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonGreen,
                              padding:         AppSpacing.buttonPadding,
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.xxlBR),
                              elevation: 0,
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

  Widget _checkItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _checked[index] = !_checked[index]),
            child: AnimatedContainer(
              duration: AppDuration.fast,
              width: 24, height: 24,
              decoration: AppStyles.checkBox(checked: _checked[index]),
              child: _checked[index]
                  ? const Icon(Icons.check_rounded,
                      size: 15, color: Colors.black)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.body)),
        ],
      ),
    );
  }
}