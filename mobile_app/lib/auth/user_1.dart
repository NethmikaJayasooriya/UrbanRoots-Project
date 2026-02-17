import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_2.dart';

// Colors
const Color screenBg = Color(0xFF0F1115);
const Color fieldBg = Color(0xFF1A1D23);
const Color glowRed = Colors.redAccent;
const Color glowGreen = Color(0xFF00FF9D);

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

  // Dropdown values
  String _gender = "";
  String _userType = "";
  final List<String> _genderOptions = ["Male", "Female", "Other"];
  final List<String> _userTypeOptions = ["Personal", "Business"];

  // Track if Next Step was clicked
  bool _submitted = false;

  // Progress bar step
  final int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Trigger rebuild when field focuses change
    [
      _firstNameFocus,
      _lastNameFocus,
      _emailFocus,
      _phoneFocus,
      _cityFocus,
      _ageFocus,
      _genderFocus,
      _userTypeFocus
    ].forEach((f) => f.addListener(() => setState(() {})));
  }

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
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: glowGreen),
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
                      color: index <= _currentStep ? glowGreen : Colors.white12,
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

            // Header
            const Text(
              "Tell us a little about yourself.",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),

            // Name Row
            Row(
              children: [
                Expanded(
                  child: _GlowTextField(
                    hint: "First Name",
                    controller: _firstNameController,
                    focusNode: _firstNameFocus,
                    submitted: _submitted,
                    validator: (text) => text.isEmpty,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _GlowTextField(
                    hint: "Last Name",
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    submitted: _submitted,
                    validator: (text) => text.isEmpty,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Email & Phone
            Row(
              children: [
                Expanded(
                  child: _GlowTextField(
                    hint: "Email",
                    controller: _emailController,
                    focusNode: _emailFocus,
                    submitted: _submitted,
                    validator: (text) =>
                    text.isEmpty || !text.contains("@"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _GlowTextField(
                    hint: "Phone Number",
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    submitted: _submitted,
                    isNumber: true,
                    validator: (text) => text.length != 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // City
            _GlowTextField(
              hint: "City / Location",
              controller: _cityController,
              focusNode: _cityFocus,
              submitted: _submitted,
              validator: (text) => text.isEmpty,
            ),
            const SizedBox(height: 25),

            // Gender & Age
            Row(
              children: [
                Expanded(
                  child: _GlowDropdown(
                    hint: "Gender",
                    currentValue: _gender,
                    options: _genderOptions,
                    focusNode: _genderFocus,
                    submitted: _submitted,
                    validator: (text) => text.isEmpty,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _GlowTextField(
                    hint: "Age",
                    controller: _ageController,
                    focusNode: _ageFocus,
                    isNumber: true,
                    submitted: _submitted,
                    validator: (text) => text.isEmpty,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // User Type
            _GlowDropdown(
              hint: "User Type",
              currentValue: _userType,
              options: _userTypeOptions,
              focusNode: _userTypeFocus,
              submitted: _submitted,
              validator: (text) => text.isEmpty,
              onChanged: (value) => setState(() => _userType = value!),
            ),
            const SizedBox(height: 35),

            // Next Step
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _submitted = true;
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
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Glow TextField Widget
class _GlowTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isNumber;
  final bool submitted;
  final bool Function(String) validator;

  const _GlowTextField({
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.submitted,
    required this.validator,
    this.isNumber = false,
  });

  @override
  State<_GlowTextField> createState() => _GlowTextFieldState();
}

class _GlowTextFieldState extends State<_GlowTextField> {
  bool get _isFocused => widget.focusNode.hasFocus;

  bool get _showRed =>
      widget.submitted && widget.validator(widget.controller.text) && !_isFocused;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color: glowGreen.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ]
            : [],
        border: Border.all(
          color: _showRed
              ? glowRed
              : _isFocused
              ? glowGreen
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType:
        widget.isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

// Glow Dropdown Widget
class _GlowDropdown extends StatefulWidget {
  final String hint;
  final String currentValue;
  final List<String> options;
  final FocusNode focusNode;
  final bool submitted;
  final bool Function(String) validator;
  final ValueChanged<String?> onChanged;

  const _GlowDropdown({
    required this.hint,
    required this.currentValue,
    required this.options,
    required this.focusNode,
    required this.submitted,
    required this.validator,
    required this.onChanged,
  });

  @override
  State<_GlowDropdown> createState() => _GlowDropdownState();
}

class _GlowDropdownState extends State<_GlowDropdown> {
  bool get _isFocused => widget.focusNode.hasFocus;

  bool get _showRed =>
      widget.submitted && widget.validator(widget.currentValue) && !_isFocused;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color: glowGreen.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ]
            : [],
        border: Border.all(
          color: _showRed
              ? glowRed
              : _isFocused
              ? glowGreen
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButton<String>(
        focusNode: widget.focusNode,
        value: widget.currentValue.isNotEmpty ? widget.currentValue : null,
        isExpanded: true,
        dropdownColor: fieldBg,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white),
        hint: Text(widget.hint,
            style: const TextStyle(color: Colors.white54, fontSize: 16)),
        onChanged: (value) {
          widget.onChanged(value);
          setState(() {});
        },
        items: widget.options
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(
            e,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ))
            .toList(),
      ),
    );
  }
}
