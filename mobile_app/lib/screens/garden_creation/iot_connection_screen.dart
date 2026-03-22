import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'manual_environment_screen.dart';
import 'garden_strategy_screen.dart';

class IoTConnectionScreen extends StatefulWidget {
  final Map<String, dynamic>? gardenData;
  final Function(Map<String, dynamic>)? onGardenCreated;

  const IoTConnectionScreen({
    super.key,
    this.gardenData,
    this.onGardenCreated,
  });

  @override
  State<IoTConnectionScreen> createState() => _IoTConnectionScreenState();
}

class _IoTConnectionScreenState extends State<IoTConnectionScreen>
    with SingleTickerProviderStateMixin {

  // ── State ──────────────────────────────────────────────────────────────────
  bool get _isStandalone => widget.onGardenCreated == null;
  bool _isScanning   = false;
  bool _isConnecting = false;
  String? _selectedDevice; // IP tapped in the list
  String? _connectedIp;    // Saved/active IP
  bool _deviceOnline = false;
  List<_Device> _foundDevices = [];

  // ── Tuning ─────────────────────────────────────────────────────────────────
  // Scan: generous timeout — we want to find slow devices
  static const Duration _scanTimeout      = Duration(milliseconds: 3000);
  // Heartbeat: short timeout — fast failure = fast disconnect detection
  static const Duration _heartbeatTimeout = Duration(milliseconds: 1200);
  // How often to ping when connected
  static const Duration _heartbeatInterval = Duration(seconds: 2);
  // How often to poll when waiting for device to return
  static const Duration _returnPollInterval = Duration(milliseconds: 800);
  // Concurrent scan requests
  static const int _concurrency = 35;

  late AnimationController _animCtrl;
  Timer? _heartbeatTimer;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _init();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('iot_device_ip');
    if (saved != null && mounted) {
      setState(() => _connectedIp = saved);
      // Verify device is actually reachable before marking online
      final alive = await _ping(saved, _heartbeatTimeout);
      if (mounted) {
        setState(() => _deviceOnline = alive);
        if (alive) {
          _startHeartbeat();
        } else {
          // It was saved but isn't reachable right now — wait for it
          _watchForReturn(saved);
        }
      }
    }
    _scanNetwork();
  }

  // ── Heartbeat: detects unplug within ~2 seconds ────────────────────────────
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) async {
      if (_connectedIp == null || !mounted) return;

      // Uses SHORT timeout — don't wait 3s to know the device is gone
      final alive = await _ping(_connectedIp!, _heartbeatTimeout);
      if (!mounted) return;

      if (!alive && _deviceOnline) {
        // Device just went offline
        setState(() => _deviceOnline = false);
        _showSnack('Sensor unplugged — reconnect it to continue', Colors.orangeAccent);
        _heartbeatTimer?.cancel();
        _watchForReturn(_connectedIp!);
      }
    });
  }

  /// Polls rapidly until the device is reachable again, then auto-resumes.
  Future<void> _watchForReturn(String ip) async {
    while (mounted && _connectedIp == ip) {
      await Future.delayed(_returnPollInterval);
      if (!mounted || _connectedIp != ip) return;

      final alive = await _ping(ip, _heartbeatTimeout);
      if (alive && mounted) {
        setState(() => _deviceOnline = true);
        _showSnack('Sensor reconnected!', AppColors.primaryGreen);
        _startHeartbeat();
        return;
      }
    }
  }

  // ── Network scan ───────────────────────────────────────────────────────────
  Future<void> _scanNetwork() async {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _foundDevices.clear();
      _selectedDevice = null;
    });

    // Try mDNS hostnames first — zero-latency if firmware supports it
    await _checkAndAdd('esp32.local',    timeout: _scanTimeout);
    await _checkAndAdd('smartsoil.local', timeout: _scanTimeout);

    try {
      if (kIsWeb) {
        await _scanSubnets(['192.168.1.', '192.168.0.', '192.168.8.', '192.168.43.', '10.0.0.']);
      } else {
        await _scanNative();
      }
    } catch (_) {}

    if (mounted) setState(() => _isScanning = false);
  }

  Future<void> _scanNative() async {
    String? localIp;
    for (final iface in await NetworkInterface.list()) {
      for (final addr in iface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          if (addr.address.startsWith('192.168.')) { localIp = addr.address; break; }
          localIp ??= addr.address;
        }
      }
      if (localIp?.startsWith('192.168.') == true) break;
    }
    if (localIp == null) return;
    await _scanSubnets([localIp.substring(0, localIp.lastIndexOf('.') + 1)]);
  }

  Future<void> _scanSubnets(List<String> subnets) async {
    for (final subnet in subnets) {
      if (!mounted || !_isScanning) return;
      final ips = List.generate(254, (i) => '$subnet${i + 1}');
      for (int off = 0; off < ips.length; off += _concurrency) {
        if (!mounted || !_isScanning) return;
        final batch = ips.sublist(off, (off + _concurrency).clamp(0, ips.length));
        await Future.wait(batch.map((ip) => _checkAndAdd(ip, timeout: _scanTimeout)));
      }
    }
  }

  // ── Probe helpers ──────────────────────────────────────────────────────────

  /// Low-level single HTTP probe against one endpoint, returns true if sensor.
  Future<bool> _ping(String ip, Duration timeout) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    for (final ep in ['/ping', '/data', '/sensor', '/']) {
      try {
        final res = await http
            .get(Uri.parse('http://$ip$ep?t=$ts'))
            .timeout(timeout);
        if (res.statusCode == 200 && _isSensor(res.body)) return true;
      } catch (_) {}
    }
    return false;
  }

  bool _isSensor(String body) {
    try {
      final d = jsonDecode(body) as Map<String, dynamic>;
      if (d['device'] == 'urban_roots_soil') return true;
      if (d.containsKey('hum') && (d.containsKey('temp') || d.containsKey('count'))) return true;
      if (d.containsKey('moisture')) return true;
    } catch (_) {}
    return false;
  }

  Future<void> _checkAndAdd(String ip, {required Duration timeout}) async {
    final found = await _ping(ip, timeout);
    if (found && mounted && !_foundDevices.any((d) => d.ip == ip)) {
      setState(() => _foundDevices.add(_Device(ip: ip, name: 'UrbanRoots Sensor')));
    }
  }

  // ── Connect / Disconnect ───────────────────────────────────────────────────
  Future<void> _connectDevice() async {
    final ip = _selectedDevice ?? _connectedIp;
    if (ip == null) return;

    setState(() {
      _isConnecting = true;
      _isScanning = false;
    });

    // Confirm device is live before saving — prevents connecting to a ghost entry
    final alive = await _ping(ip, _scanTimeout);
    if (!mounted) return;

    if (!alive) {
      setState(() => _isConnecting = false);
      _showSnack('Cannot reach sensor. Make sure it is powered on.', Colors.redAccent);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('iot_device_ip', ip);

    setState(() {
      _connectedIp  = ip;
      _deviceOnline = true;
      _isConnecting = false;
    });
    _startHeartbeat();
    
    if (_isStandalone) {
      Navigator.pop(context);
    } else {
      _showWindConfigDialog();
    }
  }

  Future<void> _disconnectDevice() async {
    _heartbeatTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('iot_device_ip');
    setState(() {
      _connectedIp     = null;
      _deviceOnline    = false;
      _selectedDevice  = null;
    });
  }

  // ── Wind dialog ────────────────────────────────────────────────────────────
  void _showWindConfigDialog() {
    bool localWind = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          title: Text('Extra Detail',
              style: GoogleFonts.poppins(
                  color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 22)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your sensor handles soil and light, but the AI needs to know about wind for 100% accuracy.',
                style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: const Color(0xFF1F2924),
                    borderRadius: BorderRadius.circular(16)),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('High Wind Exposure?',
                      style: GoogleFonts.poppins(
                          color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('Usually for balconies above 3rd floor',
                      style: GoogleFonts.poppins(color: Colors.white30, fontSize: 11)),
                  value: localWind,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (v) => setD(() => localWind = v),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (widget.gardenData != null) {
                  widget.gardenData!['is_windy'] = localWind;
                }
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => GardenStrategyScreen(
                          gardenData: widget.gardenData ?? {},
                          onGardenCreated: widget.onGardenCreated,
                        )));
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: Text('Next',
                    style: GoogleFonts.poppins(
                        color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Button is active only when a device is selected/connected AND it is online
    final hasTarget      = _selectedDevice != null || _connectedIp != null;
    final sensorIsOnline = _connectedIp == null || _deviceOnline;
    final canConnect     = hasTarget && sensorIsOnline && !_isConnecting;

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

            // ── Title ────────────────────────────────────────────────────────
            Text('Connect your\nSmart Sensor.',
                style: GoogleFonts.poppins(
                    fontSize: 32, fontWeight: FontWeight.bold,
                    color: AppColors.textMain, height: 1.2),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('Turn on your device and bring it close.',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 40),

            // ── Radar ────────────────────────────────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _animCtrl,
                builder: (_, __) {
                  final Color ringColor = _connectedIp != null && !_deviceOnline
                      ? Colors.orangeAccent
                      : AppColors.primaryGreen;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse ring — while scanning OR while waiting for sensor return
                      if (_isScanning || (_connectedIp != null && !_deviceOnline))
                        Transform.scale(
                          scale: 1.0 + _animCtrl.value * 0.4,
                          child: Opacity(
                            opacity: 1.0 - _animCtrl.value,
                            child: Container(
                              height: 170, width: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: ringColor.withOpacity(0.4), width: 2),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        height: 150, width: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceColor,
                          border: Border.all(
                            color: _isScanning
                                ? AppColors.primaryGreen.withOpacity(0.5)
                                : _connectedIp != null && _deviceOnline
                                    ? AppColors.primaryGreen
                                    : _connectedIp != null && !_deviceOnline
                                        ? Colors.orangeAccent
                                        : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: _isScanning
                              ? [BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.2),
                                  blurRadius: 30 * _animCtrl.value,
                                  spreadRadius: 10 * _animCtrl.value)]
                              : _connectedIp != null && _deviceOnline
                                  ? [BoxShadow(
                                      color: AppColors.primaryGreen.withOpacity(0.25),
                                      blurRadius: 20, spreadRadius: 4)]
                                  : [],
                        ),
                        child: Center(
                          child: _isScanning
                              ? const Icon(Icons.radar, size: 60, color: AppColors.primaryGreen)
                              : _connectedIp != null && _deviceOnline
                                  ? const Icon(Icons.check_circle_rounded, size: 60, color: AppColors.primaryGreen)
                                  : _connectedIp != null && !_deviceOnline
                                      ? const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.orangeAccent)
                                      : const Icon(Icons.wifi_tethering, size: 60, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ── Status label ─────────────────────────────────────────────────
            Text(
              _isScanning
                  ? 'Scanning...'
                  : _connectedIp != null && !_deviceOnline
                      ? 'Sensor unplugged — plug it back in'
                      : _connectedIp != null
                          ? 'Sensor Online'
                          : _foundDevices.isEmpty
                              ? 'No Devices Found'
                              : 'Devices Found',
              style: GoogleFonts.poppins(
                color: _connectedIp != null && !_deviceOnline
                    ? Colors.orangeAccent
                    : AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),

            // ── Connected banner ──────────────────────────────────────────────
            if (_connectedIp != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: (_deviceOnline ? AppColors.primaryGreen : Colors.orangeAccent)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _deviceOnline ? AppColors.primaryGreen : Colors.orangeAccent),
                ),
                child: Row(
                  children: [
                    Icon(
                      _deviceOnline ? Icons.sensors : Icons.sensors_off_rounded,
                      color: _deviceOnline ? AppColors.primaryGreen : Colors.orangeAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _deviceOnline ? 'Connected' : 'Reconnecting…',
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(_connectedIp!,
                              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _disconnectDevice,
                      child: Text('REMOVE',
                          style: GoogleFonts.poppins(
                              color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Device list ───────────────────────────────────────────────────
            Expanded(
              child: _isScanning && _foundDevices.isEmpty
                  ? const SizedBox()
                  : _foundDevices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off, color: Colors.white12, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No devices detected.\nMake sure the sensor is powered on.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(color: Colors.white24, fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              TextButton.icon(
                                onPressed: _isScanning ? null : _scanNetwork,
                                icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
                                label: Text('Retry Scan',
                                    style: GoogleFonts.poppins(color: AppColors.primaryGreen)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _foundDevices.length,
                          itemBuilder: (_, i) {
                            final dev   = _foundDevices[i];
                            final isSel = _selectedDevice == dev.ip;
                            final isAct = _connectedIp   == dev.ip;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedDevice = dev.ip),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSel || isAct
                                      ? Border.all(color: AppColors.primaryGreen, width: 2)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.devices, color: Colors.white70),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(dev.name,
                                              style: GoogleFonts.poppins(
                                                  color: AppColors.textMain,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500)),
                                          Text(dev.ip,
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white38, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    if (isSel || isAct)
                                      const Icon(Icons.check_circle,
                                          color: AppColors.primaryGreen, size: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // ── Connect button ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                // BLOCKED when sensor is saved but currently offline
                onPressed: canConnect ? _connectDevice : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor: AppColors.surfaceColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 24, width: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                    : Text(
                        // Show contextual label based on state
                        _connectedIp != null && !_deviceOnline
                            ? 'Waiting for Sensor...'
                            : _connectedIp != null
                                ? 'Continue'
                                : 'Connect Device',
                        style: GoogleFonts.poppins(
                            color: canConnect ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                if (_isStandalone) {
                  Navigator.pop(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManualEnvironmentScreen(
                        gardenData: widget.gardenData ?? {},
                        onGardenCreated: widget.onGardenCreated,
                      ),
                    ),
                  );
                }
              },
              child: Text('Skip for now',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Model ──────────────────────────────────────────────────────────────────────
class _Device {
  final String ip;
  final String name;
  const _Device({required this.ip, required this.name});
}