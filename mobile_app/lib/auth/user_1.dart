import 'package:flutter/material.dart';

class UserProfile1 extends StatefulWidget {
  const UserProfile1({super.key});

  @override
  State<UserProfile1> createState() => Profile1Screen();
}

class Profile1Screen extends State<UserProfile1> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _experienceLevel = "Beginner level";
  String _smartSensor = "Maybe later";

  final List<String> _experienceOptions = [
    "Beginner level",
    "Intermediate level",
    "Expert level"
  ];

  final List<String> _sensorOptions = [
    "Yes",
    "No",
    "Maybe later",
  ];

  // For multi-step progress
   int _currentStep = 0; // 0 = first step, 1 = second step, etc.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.greenAccent),
        title: const Text(
          "Who are you?",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Multi-step progress bar (3 bars)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? Colors.greenAccent
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Top image
            Center(
              child: Image.asset(
                'assets/user1.png',
                width: 200,
                height: 320,
              ),
            ),
            const SizedBox(height: 20),

            // Display Name
            _buildTextField(_nameController, "Enter your name"),
            const SizedBox(height: 15),

            // Phone Number
            _buildTextField(_phoneController, "Enter your number"),
            const SizedBox(height: 15),

            // Experience Level Dropdown
            _buildDropdown(
              "Experience level",
              _experienceLevel,
              _experienceOptions,
                  (value) {
                setState(() {
                  _experienceLevel = value!;
                });
              },
            ),
            const SizedBox(height: 15),

            // Smart Sensor Dropdown
            _buildDropdown(
              "Do you have our smart sensor?",
              _smartSensor,
              _sensorOptions,
                  (value) {
                setState(() {
                  _smartSensor = value!;
                });
              },
            ),
            const SizedBox(height: 30),

            // Next Step Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Move to next step (if within bounds)
                    if (_currentStep < 2) {
                      _currentStep++;
                    }
                  });
                  // Handle additional next step action here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Next Step",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom TextField
  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1A1D23),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Custom Dropdown
  Widget _buildDropdown(String label, String currentValue, List<String> options,
      ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D23),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButton<String>(
        value: currentValue,
        isExpanded: true,
        dropdownColor: const Color(0xFF1A1D23),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        items: options
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: const TextStyle(color: Colors.white)),
        ))
            .toList(),
      ),
    );
  }
}
