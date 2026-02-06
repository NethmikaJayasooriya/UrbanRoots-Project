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