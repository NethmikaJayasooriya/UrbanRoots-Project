import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manual_environment_screen.dart';
import 'garden_strategy_screen.dart';
import 'package:mobile_app/core/theme/app_colors.dart';

class IoTConnectionScreen extends StatefulWidget {
  final Map<String, dynamic> gardenData;
  // Callback forwarded down the chain
  final Function(Map<String, dynamic>)? onGardenCreated;

  const IoTConnectionScreen({
    super.key,
    required this.gardenData,
    this.onGardenCreated,
  });

  @override
  State<IoTConnectionScreen> createState() => _IoTConnectionScreenState();
}

class _IoTConnectionScreenState extends State<IoTConnectionScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanning = true;
  bool _isConnecting = false;
  String? _selectedDevice;
  late AnimationController _animationController;

  final List<String> _foundDevices = [
    "UrbanRoots Sensor X1",
    "Smart Garden Hub",
    "ESP32-Garden-04",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startScan();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startScan() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _isScanning = false);
      _animationController.stop();
    }
  }

  void _connectDevice() async {
    setState(() => _isConnecting = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isConnecting = false);
      _showWindConfigDialog(context);
    }
  }

  void _showWindConfigDialog(BuildContext context) {
    bool localWindState = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            title: Text(
              "Extra Detail",
              style: GoogleFonts.poppins(
                color: AppColors.textMain,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your sensor handles soil and light, but the AI needs to know about wind for 100% accuracy.",
                  style: GoogleFonts.poppins(
                    color: AppColors.textDim,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2924),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "High Wind Exposure?",
                      style: GoogleFonts.poppins(
                        color: AppColors.textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "Usually for balconies above 3rd floor",
                      style: GoogleFonts.poppins(color: Colors.white30, fontSize: 11),
                    ),
                    value: localWindState,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (val) => setDialogState(() => localWindState = val),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Enrich data bundle with IoT details
                  widget.gardenData['is_iot_connected'] = true;
                  widget.gardenData['is_windy'] = localWindState;
                  widget.gardenData['soil_type'] = "IoT Sensor Managed";
                  widget.gardenData['sunlight_level'] = 50;
                  widget.gardenData['watering_frequency'] = "Auto";

                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GardenStrategyScreen(
                        gardenData: widget.gardenData,
                        onGardenCreated: widget.onGardenCreated, // ← forward
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Text(
                    "Next",
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
        child: Column(
          children: [
            Text(
              "Connect your\nSmart Sensor.",
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Turn on your device and bring it close.",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),

            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceColor,
                      border: Border.all(
                        color: _isScanning
                            ? AppColors.primaryGreen.withOpacity(0.5)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: _isScanning
                          ? [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.2),
                                blurRadius: 30 * _animationController.value,
                                spreadRadius: 10 * _animationController.value,
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: _isScanning
                          ? const Icon(Icons.radar,
                              size: 60, color: AppColors.primaryGreen)
                          : const Icon(Icons.wifi_tethering,
                              size: 60, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isScanning ? "Scanning..." : "Devices Found",
              style: GoogleFonts.poppins(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: _isScanning
                  ? const SizedBox()
                  : ListView.builder(
                      itemCount: _foundDevices.length,
                      itemBuilder: (context, index) {
                        final deviceName = _foundDevices[index];
                        final isSelected = _selectedDevice == deviceName;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDevice = deviceName),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primaryGreen, width: 2)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.devices, color: Colors.white70),
                                const SizedBox(width: 15),
                                Text(
                                  deviceName,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textMain,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: AppColors.primaryGreen, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedDevice != null && !_isConnecting)
                    ? _connectDevice
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor: AppColors.surfaceColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 3),
                      )
                    : Text(
                        "Connect Device",
                        style: GoogleFonts.poppins(
                          color: _selectedDevice != null
                              ? Colors.black
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                widget.gardenData['is_iot_connected'] = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManualEnvironmentScreen(
                      gardenData: widget.gardenData,
                      onGardenCreated: widget.onGardenCreated, // ← forward
                    ),
                  ),
                );
              },
              child: Text(
                "Skip for now",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}