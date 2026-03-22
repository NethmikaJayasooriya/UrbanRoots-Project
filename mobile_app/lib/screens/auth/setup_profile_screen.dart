import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/screens/dashboard/nav_bar.dart';

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
  
  bool _isSubmitting = false;

  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Opens camera or gallery and updates state
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } catch (e) {
      debugPrint("Failed to pick image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to get image. Check permissions."),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // Bottom sheet for image source selection
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
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGreen),
              title: Text(
                'Take a photo',
                style: GoogleFonts.poppins(color: AppColors.textMain, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primaryGreen),
              title: Text(
                'Choose from gallery',
                style: GoogleFonts.poppins(color: AppColors.textMain, fontWeight: FontWeight.w500),
              ),
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

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Handles image upload to Supabase storage bucket
  Future<String?> _uploadProfileImageIfNeeded(String uid) async {
    if (_profileImage == null) {
      return FirebaseAuth.instance.currentUser?.photoURL;
    }

    try {
      final supabase = Supabase.instance.client;
      final fileExtension = _profileImage!.name.split('.').last;
      final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      
      final imageBytes = await _profileImage!.readAsBytes();

      await supabase.storage.from('profile_pictures').uploadBinary(
        fileName,
        imageBytes,
        fileOptions: const FileOptions(upsert: true), 
      );

      final downloadUrl = supabase.storage.from('profile_pictures').getPublicUrl(fileName);
      return downloadUrl;
    } catch (e) {
      debugPrint("Profile image upload failed: $e");
      return null;
    }
  }

  // Validates form and saves user data to PostgreSQL
  void _completeProfile() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error. Please sign in again.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : 'email/password';

      String? profilePicUrl;
      try {
        profilePicUrl = await _uploadProfileImageIfNeeded(user.uid);
        
        if (profilePicUrl != null && profilePicUrl.isNotEmpty && user.photoURL != profilePicUrl) {
          await user.updatePhotoURL(profilePicUrl);
        }
      } catch (e) {
        debugPrint("Image setup failed, continuing profile creation: $e");
        profilePicUrl = null;
      }

      await AuthService.setupProfile(
        uid: user.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : (user.email ?? ''),
        phone: _phoneController.text.trim(),
        authProvider: provider,
        profilePic: profilePicUrl,
      );

      // ── CLEAR ANY STALE DEVICE DATA FROM A PREVIOUS ACCOUNT ──
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove('active_garden_id'),
        prefs.remove('iot_device_ip'),
        prefs.remove('iot_last_alert_type'),
        prefs.remove('iot_last_alert_message'),
        prefs.remove('iot_last_alert_plant'),
        prefs.remove('iot_last_alert_time'),
        prefs.remove('scan_history'),
        prefs.remove('user_phone'),
        prefs.remove('user_phones'),
      ]);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully'),
          backgroundColor: AppColors.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Creates empty profile records and proceeds to app
  void _skipProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await AuthService.setupProfile(
          uid: user.uid,
          firstName: '',
          lastName: '',
          email: user.email ?? '',
        );
      } catch (e) {
        debugPrint("Profile skip error: $e");
      }
    }

    if (!mounted) return;

    // Navigate to the main dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPhotoUrl = FirebaseAuth.instance.currentUser?.photoURL;
    
    ImageProvider? avatarImage;
    if (_profileImage != null) {
      avatarImage = kIsWeb 
          ? NetworkImage(_profileImage!.path) as ImageProvider
          : FileImage(File(_profileImage!.path));
    } else if (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty) {
      avatarImage = NetworkImage(currentPhotoUrl);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Complete Profile",
          style: GoogleFonts.poppins(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              GestureDetector(
                onTap: _showImageSourceActionSheet,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                        image: avatarImage != null
                            ? DecorationImage(
                                image: avatarImage,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: avatarImage == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white24)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundColor,
                          width: 3,
                        ), 
                      ),
                      child: const Icon(Icons.edit, size: 18, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _buildTextField(
                "First Name",
                _firstNameController,
                Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "First name required" : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                "Last Name",
                _lastNameController,
                Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Last name required" : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                "Email",
                _emailController,
                Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Email required";
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                "Phone Number",
                _phoneController,
                Icons.phone_outlined,
                isNumber: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // Optional
                  if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(v.trim())) {
                    return "Enter a valid phone number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Text(
                          "Finish Setup",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: _isSubmitting ? null : _skipProfile,
                child: Text(
                  "Skip for now",
                  style: GoogleFonts.poppins(color: AppColors.textDim),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: GoogleFonts.poppins(color: AppColors.textMain),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceColor,
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.textDim),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
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