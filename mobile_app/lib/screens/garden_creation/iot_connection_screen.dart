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
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),]
        )))}
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
                      : const Icon(Icons.wifi_tethering,
                          size: 60, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),