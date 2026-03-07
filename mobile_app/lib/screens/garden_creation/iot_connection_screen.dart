import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manual_environment_screen.dart';
import 'garden_strategy_screen.dart';

class IoTConnectionScreen extends StatefulWidget {
  const IoTConnectionScreen({super.key});

  @override
  State<IoTConnectionScreen> createState() => _IoTConnectionScreenState();
}

class _IoTConnectionScreenState extends State<IoTConnectionScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = true;
  bool _isConnecting = false;
  String? _selectedDevice;
  late AnimationController _animationController;

  final List<String> _foundDevices = [
    "UrbanRoots Sensor X1", "Smart Garden Hub", "ESP32-Garden-04"
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

  // UPDATED DIALOG: Fixes the "tight" look by adding proper padding and spacing
  void _showWindConfigDialog(BuildContext context) {
    bool localWindState = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          const neonGreen = Color(0xFF00E676);
          const surfaceColor = Color(0xFF16201B);
          const boxColor = Color(0xFF1F2924); // Slightly lighter for contrast

          return AlertDialog(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            title: Text("Extra Detail", 
              style: GoogleFonts.poppins(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 22
              )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your sensor handles soil and light, but the AI needs to know about wind for 100% accuracy.",
                  style: GoogleFonts.poppins(
                    color: Colors.white54, 
                    fontSize: 13, 
                    height: 1.5
                  ),
                ),
                const SizedBox(height: 24),
                
                // FIXED BOX: Increased internal padding
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero, 
                    title: Text("High Wind Exposure?", 
                      style: GoogleFonts.poppins(
                        color: Colors.white, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600
                      )),
                    subtitle: Text("Usually for balconies above 3rd floor", 
                      style: GoogleFonts.poppins(
                        color: Colors.white30, 
                        fontSize: 11
                      )),
                    value: localWindState,
                    activeColor: neonGreen,
                    onChanged: (val) => setDialogState(() => localWindState = val),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const GardenStrategyScreen())
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Text("Next", 
                    style: GoogleFonts.poppins(
                      color: neonGreen, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )),
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
    const bgColor = Color(0xFF07160F);
    const surfaceColor = Color(0xFF16201B);
    const neonGreen = Color(0xFF00E676);

    return Scaffold(
      backgroundColor: bgColor,
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
        child: Column(
          children: [
            Text("Connect your\nSmart Sensor.",
                style: GoogleFonts.poppins(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white, 
                  height: 1.2
                ), 
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text("Turn on your device and bring it close.", 
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 40),

            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    height: 150, width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: surfaceColor,
                      border: Border.all(
                        color: _isScanning ? neonGreen.withOpacity(0.5) : Colors.transparent, 
                        width: 2
                      ),
                      boxShadow: _isScanning 
                        ? [BoxShadow(
                            color: neonGreen.withOpacity(0.2), 
                            blurRadius: 30 * _animationController.value, 
                            spreadRadius: 10 * _animationController.value
                          )] 
                        : [],
                    ),
                    child: Center(
                      child: _isScanning
                          ? const Icon(Icons.radar, size: 60, color: neonGreen)
                          : const Icon(Icons.wifi_tethering, size: 60, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(_isScanning ? "Scanning..." : "Devices Found", 
                style: GoogleFonts.poppins(
                  color: neonGreen, 
                  fontWeight: FontWeight.w600, 
                  fontSize: 16
                )),
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
                          onTap: () => setState(() => _selectedDevice = deviceName),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16), // Matching the squircle theme
                              border: isSelected ? Border.all(color: neonGreen, width: 2) : null,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.devices, color: Colors.white70),
                                const SizedBox(width: 15),
                                Text(deviceName, 
                                  style: GoogleFonts.poppins(
                                    color: Colors.white, 
                                    fontSize: 15, 
                                    fontWeight: FontWeight.w500
                                  )),
                                const Spacer(),
                                if (isSelected) const Icon(Icons.check_circle, color: neonGreen, size: 20),
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
                onPressed: (_selectedDevice != null && !_isConnecting) ? _connectDevice : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonGreen,
                  disabledBackgroundColor: surfaceColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3)
                      )
                    : Text("Connect Device", 
                        style: GoogleFonts.poppins(
                          color: _selectedDevice != null ? Colors.black : Colors.grey, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 16
                        )),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ManualEnvironmentScreen())
              ),
              child: Text("Skip for now", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}