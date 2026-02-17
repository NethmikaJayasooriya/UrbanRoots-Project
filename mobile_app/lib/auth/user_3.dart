import 'package:flutter/material.dart';

class Profile3Screen extends StatefulWidget {
  const Profile3Screen({super.key});

  @override
  State<Profile3Screen> createState() => _Profile3ScreenState();
}

class _Profile3ScreenState extends State<Profile3Screen> {
  final Color glowGreen = const Color(0xFF00FF9D);
  final Color glowRed = Colors.redAccent;

  bool _submitted = false;

  // Sustainability Goals (single choice)
  final List<String> _sustainabilityGoals = [
    "Reduce waste",
    "Save energy",
    "Buy eco-friendly products",
    "Support local green businesses",
    "Learn about sustainability"
  ];
  String _selectedGoal = "";

  // Sustainability Tips (single choice)
  final List<String> _tipsFrequency = ["Daily", "Weekly", "Only when important", "Never"];
  String _selectedTipsFrequency = "";

  // Commitment slider
  double _commitmentLevel = 1;

  // Community Preferences
  final List<String> _communityOptions = [
    "Join discussion forums",
    "Follow local sellers",
    "Participate in events",
    "Share tips & ideas",
    "No participation"
  ];
  final Set<String> _selectedCommunity = {};
  String _communitySingleSelect = ""; // for single-select options

  // Community notifications (single-select)
  final List<String> _communityNotifications = [
    "Notify me about all updates",
    "Only major updates",
    "No notifications"
  ];
  String _selectedCommunityNotifications = "";

  // App notifications (single-select)
  final List<String> _appNotifications = [
    "Offers & updates",
    "Important only",
    "None"
  ];
  String _selectedAppNotifications = "";

  // Dashboard view (single-select)
  final List<String> _dashboardOptions = [
    "Show recommended products",
    "Show trending products",
    "Show both",
    "Minimal view"
  ];
  String _selectedDashboard = "";

  final int currentStep = 2; // step 3 of 3

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: glowGreen),
        title: const Text(
          "Smart Features & Device Preferences",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar (Step 3 of 3)
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
              const SizedBox(height: 25),

              const Text(
                "Almost There!\nCustomize how Urban Roots connects with your smart devices.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Sustainability Goals
              const Text(
                "What are your sustainability goals?",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildSingleSelect(_sustainabilityGoals, _selectedGoal,
                      (val) => _selectedGoal = val, requiredField: true),
              const SizedBox(height: 30),

              // Tips Frequency
              const Text(
                "How often would you like sustainability tips?",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildSingleSelect(_tipsFrequency, _selectedTipsFrequency,
                      (val) => _selectedTipsFrequency = val,
                  requiredField: true),
              const SizedBox(height: 30),

              // Commitment Slider
              const Text(
                "How committed are you to these goals? (1 = Just starting, 5 = Fully committed)",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Slider(
                value: _commitmentLevel,
                min: 1,
                max: 5,
                divisions: 4,
                label: _commitmentLevel.round().toString(),
                activeColor: glowGreen,
                inactiveColor: Colors.white12,
                onChanged: (value) {
                  setState(() {
                    _commitmentLevel = value;
                  });
                },
              ),
              const SizedBox(height: 30),

              // Community Preferences
              const Text(
                "How would you like to connect with the community?",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildMultiSelect(_communityOptions, _selectedCommunity),
              const SizedBox(height: 30),

              // Community Notifications
              const Text(
                "Community notifications preference:",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildSingleSelect(_communityNotifications,
                  _selectedCommunityNotifications,
                      (val) => _selectedCommunityNotifications = val,
                  requiredField: true),
              const SizedBox(height: 30),

              // App Notifications
              const Text(
                "App notifications preference:",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildSingleSelect(
                  _appNotifications, _selectedAppNotifications,
                      (val) => _selectedAppNotifications = val, requiredField: true),
              const SizedBox(height: 30),

              // Dashboard view
              const Text(
                "Dashboard view:",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildSingleSelect(
                  _dashboardOptions, _selectedDashboard,
                      (val) => _selectedDashboard = val, requiredField: true),
              const SizedBox(height: 40),

              // Finish Setup Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _submitted = true);

                    bool valid = _selectedGoal.isNotEmpty &&
                        _selectedTipsFrequency.isNotEmpty &&
                        _selectedCommunityNotifications.isNotEmpty &&
                        _selectedAppNotifications.isNotEmpty &&
                        _selectedDashboard.isNotEmpty &&
                        _selectedCommunity.isNotEmpty;

                    if (!valid) return;

                    // TODO: Navigate to main dashboard or next screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: glowGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Finish Setup",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Multi-select
  Widget _buildMultiSelect(List<String> options, Set<String> selectedValues) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final bool isSelected = selectedValues.contains(option);
        final bool showRed = _submitted && selectedValues.isEmpty;

        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              selectedValues.remove(option);
            } else {
              selectedValues.add(option);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: showRed ? glowRed : (isSelected ? glowGreen : Colors.white12),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: glowGreen, blurRadius: 15, spreadRadius: 2)]
                  : [],
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Single-select
  Widget _buildSingleSelect(
      List<String> options, String selectedValue, ValueChanged<String> onSelected,
      {bool requiredField = false}) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final bool isSelected = option == selectedValue;
        final bool showRed = _submitted && requiredField && selectedValue.isEmpty;

        return GestureDetector(
          onTap: () => setState(() => onSelected(option)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: showRed ? glowRed : (isSelected ? glowGreen : Colors.white12),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: glowGreen, blurRadius: 15, spreadRadius: 2)]
                  : [],
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
