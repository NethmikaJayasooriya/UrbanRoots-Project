import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IoTConnectionScreen extends StatefulWidget {
  const IoTConnectionScreen({super.key});

  @override
  State<IoTConnectionScreen> createState() => _IoTConnectionScreenState();
}

class _IoTConnectionScreenState extends State<IoTConnectionScreen> {
  // connection state variables
  bool _isScanning = true;
  bool _isConnecting = false;
  String? _selectedDevice;

  // mock list of devices
  final List<String> _foundDevices = [
    "UrbanRoots Sensor X1",
    "Smart Garden Hub",
    "ESP32-Garden-04"
  ];

  @override
  void initState() {
    super.initState();
    // simulate scanning delay
    _startScan();
  }

  void _startScan() async {
    // wait 3 seconds then show devices
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }
  // simulate connecting to a device
  void _connectDevice() async {
    setState(() => _isConnecting = true);
    // wait 2 seconds to simulate connection
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isConnecting = false);
      
      // show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connected Successfully! 🌱"),
          backgroundColor: Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      //Navigate to Dashboard
      print("Navigate to Dashboard");
    }
  }

  @override
  Widget build(BuildContext context) {
    // theme colors
    const bgColor = Color(0xFF121413);
    const surfaceColor = Color(0xFF1E2220);
    const neonGreen = Color(0xFF00E676);

    return Scaffold(
      backgroundColor: bgColor,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title section
            Text(
              "Connect your\nSmart Sensor.",
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Turn on your device and bring it close to your phone.",
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),

            // scanning animation area
            Center(
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surfaceColor,
                  border: Border.all(
                    color: _isScanning
                        ? neonGreen.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: _isScanning
                      ? [
                          BoxShadow(
                            color: neonGreen.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: _isScanning
                      ? const CircularProgressIndicator(color: neonGreen)
                      : const Icon(
                          Icons.wifi_tethering,
                          size: 60,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // status text
            Center(
              child: Text(
                _isScanning ? "Scanning for devices..." : "Devices Found",
                style: GoogleFonts.poppins(
                  color: neonGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // device list section
            Expanded(
              child: _isScanning
                  ? const SizedBox()
                  : ListView.builder(
                      itemCount: _foundDevices.length,
                      itemBuilder: (context, index) {
                        final deviceName = _foundDevices[index];
                        final isSelected = _selectedDevice == deviceName;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDevice = deviceName);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: neonGreen, width: 2)
                                  : Border.all(color: Colors.transparent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.devices,
                                        color: Colors.white70),
                                    const SizedBox(width: 15),
                                    Text(
                                      deviceName,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: neonGreen, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            
            // connect button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // Only enable button if a device is selected AND not currently loading
                onPressed: (_selectedDevice != null && !_isConnecting)
                    ? _connectDevice
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonGreen,
                  // gray color when disabled
                  disabledBackgroundColor: surfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        "Connect Device",
                        style: GoogleFonts.poppins(
                          // Black text if ready, Grey if disabled
                          color: _selectedDevice != null
                              ? Colors.black
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}