import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

// IMPORTANT: Adjust these import paths to match your actual folder structure
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/screens/garden_creation/garden_intro_screen.dart';

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

  // --- Image Picker Logic ---
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Opens camera or gallery and saves the file to state
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compresses image to save memory and upload time
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Failed to pick image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to get image. Check permissions.")),
      );
    }
  }

  // Sleek bottom sheet for user to choose camera or gallery
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGreen),
              title: Text('Take a photo', style: GoogleFonts.poppins(color: AppColors.textMain, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primaryGreen),
              title: Text('Choose from gallery', style: GoogleFonts.poppins(color: AppColors.textMain, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  // --------------------------

  void _completeProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Upload _profileImage to Firebase Storage here before navigating
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GardenIntroScreen()),
      );
    }
  }

  void _skipProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GardenIntroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Complete Profile", style: GoogleFonts.poppins(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Interactive Profile Picture Avatar Frame
              GestureDetector(
                onTap: _showImageSourceActionSheet,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGreen, width: 2),
                        // Dynamically show the picked image if it exists
                        image: _profileImage != null
                            ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                            : null,
                      ),
                      // Only show the placeholder icon if no image is selected
                      child: _profileImage == null 
                          ? const Icon(Icons.person, size: 60, color: Colors.white24)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen, 
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.backgroundColor, width: 3) // Creates a cutout effect
                      ),
                      child: const Icon(Icons.edit, size: 18, color: Colors.black),
                    ),
                  ],
                ),
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
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Finish Setup", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: _skipProfile, 
                child: Text("Skip for now", style: GoogleFonts.poppins(color: AppColors.textDim))
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
      style: GoogleFonts.poppins(color: AppColors.textMain),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceColor,
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.textDim),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        errorStyle: GoogleFonts.poppins(color: AppColors.danger, fontSize: 12),
      ),
    );
  }
}