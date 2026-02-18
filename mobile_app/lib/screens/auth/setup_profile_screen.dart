import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  void _completeProfile() {
    // Check all fields before finishing
    if (_formKey.currentState!.validate()) {
       // Proceed to Home/Dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF07160F);
    const neonGreen = Color(0xFF00E676);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Complete Profile", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16201B),
                      shape: BoxShape.circle,
                      border: Border.all(color: neonGreen, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 60, color: Colors.white24),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: neonGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              _buildTextField("First Name", _firstNameController, Icons.person_outline, 
                validator: (v) => (v == null || v.isEmpty) ? "First name required" : null),
              const SizedBox(height: 16),
              
              _buildTextField("Last Name", _lastNameController, Icons.person_outline,
                validator: (v) => (v == null || v.isEmpty) ? "Last name required" : null),
              const SizedBox(height: 16),
              
              _buildTextField("Email", _emailController, Icons.email_outlined,
                validator: (v) => (v == null || !v.contains('@')) ? "Enter valid email" : null),
              const SizedBox(height: 16),
              
              _buildTextField("Phone Number", _phoneController, Icons.phone_outlined, isNumber: true,
                validator: (v) => (v == null || v.length < 10) ? "Enter valid phone number" : null),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Finish Setup", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  // Skip logic
                }, 
                child: Text("Skip for now", style: GoogleFonts.poppins(color: Colors.white54))
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon, {bool isNumber = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF16201B),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white30),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00E676)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }
}