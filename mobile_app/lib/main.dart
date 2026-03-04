import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'leaf_disease_screen.dart';
import 'scan_history_screen.dart';

void main() {
  runApp(const UrbanRootsApp());
}

class UrbanRootsApp extends StatelessWidget {
  const UrbanRootsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanRoots',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _serverMessage = "No data yet";

  Future<void> fetchBackendData() async {
    String url;

    if (kIsWeb) {
      url = 'http://localhost:3000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      url = 'http://10.0.2.2:3000';
    } else {
      url = 'http://localhost:3000';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _serverMessage = "Backend says: ${response.body}";
        });
      } else {
        setState(() {
          _serverMessage = "Error: Server returned ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _serverMessage = "Connection Failed! \nIs NestJS running?";
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UrbanRoots v0.1")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Your Digital Plant",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[200],
              child: Text(_serverMessage, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),

            // Test connection button
            ElevatedButton(
              onPressed: fetchBackendData,
              child: const Text("Test Connection"),
            ),
            const SizedBox(height: 12),

            // Scan Leaf button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LeafScanScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text("Scan Leaf for Disease"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),

            // Scan History button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScanHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text("Scan History"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}