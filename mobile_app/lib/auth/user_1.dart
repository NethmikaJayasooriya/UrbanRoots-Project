import 'package:flutter/material.dart';

void main() {
  runApp(const Profile1App());
}

class Profile1App extends StatelessWidget {
  const Profile1App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Profile1Screen(),
    );
  }
}

class Profile1Screen extends StatelessWidget {
  const Profile1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1E1B),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Who are you?",
                style: TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 25),
            _field("Display name"),
            const SizedBox(height: 15),
            _field("Phone number"),
            const SizedBox(height: 15),
            _dropdown("Experience level"),
            const SizedBox(height: 15),
            _dropdown("Do you have smart sensor?"),
            const SizedBox(height: 25),
            _button("Next Step"),
          ],
        ),
      ),
    );
  }

  Widget _field(String hint) => TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF143C35),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _dropdown(String hint) => DropdownButtonFormField<String>(
        dropdownColor: const Color(0xFF143C35),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFF143C35),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: ["Option 1", "Option 2"]
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (_) {},
      );

  Widget _button(String text) => Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.greenAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(text)),
      );
}
