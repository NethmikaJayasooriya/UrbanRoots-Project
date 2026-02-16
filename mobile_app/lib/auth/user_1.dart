import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_2.dart';

class UserProfile1 extends StatefulWidget {
  const UserProfile1({super.key});

  @override
  State<UserProfile1> createState() => Profile1Screen();
}

class Profile1Screen extends State<UserProfile1> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _experienceFocus = FocusNode();
  final FocusNode _sensorFocus = FocusNode();

  // Glow Green
  final Color glowGreen = const Color(0xFF00FF9D);

  String _experienceLevel = "";
  String _smartSensor = "";

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

  final int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _experienceFocus.dispose();
    _sensorFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: glowGreen),
        title: const Text(
          "Who are you?",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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
                        color: index <= _currentStep ? glowGreen : Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),

              // Image
              Center(
                child: Image.asset(
                  'assets/user.png',
                  width: 200,
                  height: 180,
                ),
              ),
              const SizedBox(height: 10),

              // Name
              const Text(
                "Name",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 6),
              _buildTextField(_nameController, "Enter your name", _nameFocus),
              const SizedBox(height: 18),

              // Phone
              const Text(
                "Phone Number",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 6),
              _buildPhoneField(),
              const SizedBox(height: 18),

              // Experience Dropdown
              const Text(
                "Experience Level",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 6),
              _buildDropdown(
                  _experienceLevel, _experienceOptions, (value) {
                setState(() {
                  _experienceLevel = value!;
                });
              }, _experienceFocus),
              const SizedBox(height: 18),

              // Sensor Dropdown
              const Text(
                "Do you have our smart sensor?",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 6),
              _buildDropdown(_smartSensor, _sensorOptions, (value) {
                setState(() {
                  _smartSensor = value!;
                });
              }, _sensorFocus),
              const SizedBox(height: 90),

              // Next Step Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _phoneController.text.length != 10 ||
                        _experienceLevel.isEmpty ||
                        _smartSensor.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields correctly (phone must be 10 digits)"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfile2(),
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
            ],
          ),
        ),
      ),
    );
  }

  // Standard Glowing TextField
  Widget _buildTextField(
      TextEditingController controller, String hint, FocusNode focusNode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: focusNode.hasFocus
            ? [
          BoxShadow(
            color: glowGreen,
            blurRadius: 15,
            spreadRadius: 2,
          )
        ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 16),
          filled: true,
          fillColor: const Color(0xFF1A1D23),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onTap: () => setState(() {}),
      ),
    );
  }

  // Phone Field (digits only, max 10)
  Widget _buildPhoneField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: _phoneFocus.hasFocus
            ? [
          BoxShadow(
            color: glowGreen,
            blurRadius: 15,
            spreadRadius: 2,
          )
        ]
            : [],
      ),
      child: TextField(
        controller: _phoneController,
        focusNode: _phoneFocus,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          hintText: "Enter your number",
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 16),
          filled: true,
          fillColor: const Color(0xFF1A1D23),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onTap: () => setState(() {}),
      ),
    );
  }

  // Glowing Dropdown
  Widget _buildDropdown(String currentValue, List<String> options,
      ValueChanged<String?> onChanged, FocusNode focusNode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: focusNode.hasFocus
            ? [
          BoxShadow(
            color: glowGreen,
            blurRadius: 15,
            spreadRadius: 2,
          )
        ]
            : [],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(30),
        ),
        child: DropdownButton<String>(
          focusNode: focusNode,
          value: currentValue.isNotEmpty ? currentValue : null,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1D23),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          underline: const SizedBox(),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            onChanged(value);
            setState(() {});
          },
          hint: const Text(
            "Select an option",
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          items: options
              .map(
                (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
