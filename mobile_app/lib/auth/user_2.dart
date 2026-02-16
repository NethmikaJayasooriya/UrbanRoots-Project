import 'package:flutter/material.dart';
import 'user_3.dart';

class UserProfile2 extends StatefulWidget {
  const UserProfile2({super.key});

  @override
  State<UserProfile2> createState() => _UserProfile2State();
}

class _UserProfile2State extends State<UserProfile2> {
  final Color glowGreen = const Color(0xFF00FF9D);

  // Selected values
  String _landSize = "";
  String _climateExposure = "";
  String _timeSpent = "";

  // Options
  final List<String> _landOptions = [
    "Balcony/Pots",
    "Small Garden",
    "Medium Farm",
  ];

  final List<String> _climateOptions = [
    "Full Sun",
    "Partial Shade",
    "Indoor",
  ];

  final List<String> _timeOptions = [
    "Daily",
    "Few times a week",
    "Weekends only",
  ];

  final int currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: glowGreen),
        title: const Text(
          "Your Growing Environment",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            Padding(
              padding: const EdgeInsets.only(bottom: 90), // leave space for button
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar
                    Row(
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 4,
                            decoration: BoxDecoration(
                              color: index <= currentStep ? glowGreen : Colors.white12,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Tell us where and how you grow",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 20),

                    // Land Size
                    const Text(
                      "Land Size",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    _buildOptions(_landOptions, _landSize, (value) {
                      setState(() => _landSize = value);
                    }),
                    const SizedBox(height: 25),

                    // Climate Exposure
                    const Text(
                      "Climate Exposure",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    _buildOptions(_climateOptions, _climateExposure, (value) {
                      setState(() => _climateExposure = value);
                    }),
                    const SizedBox(height: 25),

                    // Time Spent
                    const Text(
                      "Time you can spend",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    _buildOptions(_timeOptions, _timeSpent, (value) {
                      setState(() => _timeSpent = value);
                    }),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Next Step Button
            Positioned(
              left: 24,
              right: 24,
              bottom: 0,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_landSize.isEmpty ||
                        _climateExposure.isEmpty ||
                        _timeSpent.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Profile3Screen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: glowGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Next Step",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Option buttons with glow effect
  Widget _buildOptions(List<String> options, String selectedValue, ValueChanged<String> onSelected) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final bool isSelected = option == selectedValue;

        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(30),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: glowGreen,
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ]
                  : [],
              border: Border.all(
                color: isSelected ? glowGreen : Colors.white12,
                width: 2,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
