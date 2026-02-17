import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_2.dart';

class UserProfile1 extends StatefulWidget {
  const UserProfile1({super.key});

  @override
  State<UserProfile1> createState() => Profile1Screen();
}

class Profile1Screen extends State<UserProfile1> {
  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // FocusNodes
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _genderFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();
  final FocusNode _userTypeFocus = FocusNode();

  // Glow colors
  final Color glowRed = Colors.redAccent;

  // Dropdown values
  String _gender = "";
  String _userType = "";

  final List<String> _genderOptions = ["Male", "Female", "Other"];
  final List<String> _userTypeOptions = ["Personal", "Business"];

  // Track invalid fields after Next Step is clicked
  bool _submitted = false;

  // Progress bar step (0-based)
  final int _currentStep = 0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _ageController.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _cityFocus.dispose();
    _genderFocus.dispose();
    _ageFocus.dispose();
    _userTypeFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.greenAccent),
        title: const Text(
          "Let's get started",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                      color: index <= _currentStep ? Colors.greenAccent : Colors
                          .white12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Top Image
            Center(
              child: Image.asset(
                'assets/user.png',
                width: 180,
                height: 180,
              ),
            ),
            const SizedBox(height: 20),

            // Header Text
            const Text(
              "Tell us a little about yourself.",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),

            // Name Row (First & Last)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                      _firstNameController, "First Name", _firstNameFocus,
                      isInvalid: _submitted &&
                          _firstNameController.text.isEmpty),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTextField(
                      _lastNameController, "Last Name", _lastNameFocus,
                      isInvalid: _submitted &&
                          _lastNameController.text.isEmpty),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Email & Phone
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_emailController, "Email", _emailFocus,
                      isEmail: true,
                      isInvalid: _submitted &&
                          (!_emailController.text.contains("@") ||
                              _emailController.text.isEmpty)),
                ),
                const SizedBox(width: 15),
                Expanded(
                    child: _buildPhoneField(
                        isInvalid: _submitted &&
                            _phoneController.text.length != 10)),
              ],
            ),
            const SizedBox(height: 25),

            // City / Location
            _buildTextField(_cityController, "City / Location", _cityFocus,
                isInvalid: _submitted && _cityController.text.isEmpty),
            const SizedBox(height: 25),

            // Gender & Age
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(_gender, _genderOptions, (value) {
                    setState(() {
                      _gender = value!;
                    });
                  }, _genderFocus,
                      hint: "Gender", isInvalid: _submitted && _gender.isEmpty),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTextField(_ageController, "Age", _ageFocus,
                      isNumber: true,
                      isInvalid: _submitted && _ageController.text.isEmpty),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // User Type
            _buildDropdown(_userType, _userTypeOptions, (value) {
              setState(() {
                _userType = value!;
              });
            }, _userTypeFocus,
                hint: "User Type", isInvalid: _submitted && _userType.isEmpty),
            const SizedBox(height: 35),

            // Next Step Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _submitted = true; // Only after Next Step
                  });

                  bool valid = _firstNameController.text.isNotEmpty &&
                      _lastNameController.text.isNotEmpty &&
                      _emailController.text.contains("@") &&
                      _phoneController.text.length == 10 &&
                      _cityController.text.isNotEmpty &&
                      _ageController.text.isNotEmpty &&
                      _gender.isNotEmpty &&
                      _userType.isNotEmpty;

                  if (!valid) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfile2(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
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

  Widget _buildTextField(TextEditingController controller, String hint,
      FocusNode focusNode,
      {bool isNumber = false, bool isEmail = false, bool isInvalid = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isInvalid ? glowRed : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: isNumber
            ? TextInputType.number
            : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 16),
          filled: true,
          fillColor: const Color(0xFF1A1D23),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildPhoneField({bool isInvalid = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isInvalid ? glowRed : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _phoneController,
        focusNode: _phoneFocus,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10)
        ],
        decoration: InputDecoration(
          hintText: "Phone Number",
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 16),
          filled: true,
          fillColor: const Color(0xFF1A1D23),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildDropdown(String currentValue, List<String> options,
      ValueChanged<String?> onChanged, FocusNode focusNode,
      {String hint = "Select", bool isInvalid = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isInvalid ? glowRed : Colors.transparent,
          width: 1.5,
        ),
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
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          onChanged: (value) {
            onChanged(value);
            setState(() {});
          },
          items: options
              .map((e) =>
              DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style:
                  const TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ))
              .toList(),
        ),
      ),
    );
  }
}
