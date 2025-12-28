import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; 

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

  // Function to ask Backend for data
  Future<void> fetchBackendData() async {
    String url;

    //URL SELECTION:
    if (kIsWeb) {
      // Running on Chrome/Edge
      url = 'http://localhost:3000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Running on Android Emulator
      url = 'http://10.0.2.2:3000';
    } else {
      // Running on Windows Desktop
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
            ElevatedButton(
              onPressed: fetchBackendData,
              child: const Text("Test Connection"),
            ),
          ],
        ),
      ),
    );
  }
}