import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/api/api_service.dart';
// import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  // Combined state variables from both branches
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? _existingPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email.text = user.email ?? '';
      _existingPhotoUrl = user.photoURL;

      if (user.displayName != null && user.displayName!.isNotEmpty) {
        final parts = user.displayName!.split(' ');
        firstName.text = parts.first;
        if (parts.length > 1) {
          lastName.text = parts.sublist(1).join(' ');
        }
      }

      try {
        final profile = await ApiService.getProfile();
        if (mounted) {
          setState(() {
            if (profile['first_name'] != null && profile['first_name'].toString().trim().isNotEmpty) {
              firstName.text = profile['first_name'];
            }
            if (profile['last_name'] != null && profile['last_name'].toString().trim().isNotEmpty) {
              lastName.text = profile['last_name'];
            }
            if (profile['phone'] != null && profile['phone'].toString().trim().isNotEmpty) {
              phone.text = profile['phone'];
            }
            if (profile['profile_image_url'] != null && profile['profile_image_url'].toString().trim().isNotEmpty) {
              _existingPhotoUrl = profile['profile_image_url'];
            }
          });
        }
      } catch (e) {
        // Silently fail, leaving Firebase fields as fallback
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    try {
      // Using ApiService from the HEAD branch.
      await ApiService.updateProfile(
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Profile updated successfully!",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.accent,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Choose Profile Picture",
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _BottomSheetOption(
                      icon: Icons.photo_library_outlined,
                      title: "Choose from Gallery",
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    const SizedBox(height: 10),
                    _BottomSheetOption(
                      icon: Icons.camera_alt_outlined,
                      title: "Take a Photo",
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    if (_profileImage != null) ...[
                      const SizedBox(height: 10),
                      _BottomSheetOption(
                        icon: Icons.delete_outline_rounded,
                        title: "Remove Photo",
                        isDanger: true,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _profileImage = null;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkResponse(
                          onTap: () => Navigator.pop(context),
                          radius: 26,
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.accent,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Personal Info",
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: SizedBox(
                        width: 128,
                        height: 128,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.accent.withOpacity(0.45),
                                  width: 3,
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                  image: _profileImage != null
                                      ? DecorationImage(
                                          image: FileImage(_profileImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _profileImage == null && _existingPhotoUrl == null
                                    ? const Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 52,
                                          color: AppColors.muted,
                                        ),
                                      )
                                    : _profileImage == null && _existingPhotoUrl != null
                                        ? ClipOval(
                                            child: Image.network(
                                              _existingPhotoUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : null,
                              ),
                            ),
                            Positioned(
                              right: 4,
                              bottom: 8,
                              child: InkWell(
                                onTap: _showImagePickerOptions,
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.bg,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(
                                          0.25,
                                        ),
                                        blurRadius: 16,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "PERSONAL DETAILS",
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _Card(
                      child: Column(
                        children: [
                          _InputField(
                            label: "First Name",
                            controller: firstName,
                          ),
                          const _Divider(),
                          _InputField(label: "Last Name", controller: lastName),
                          const _Divider(),
                          _InputField(
                            label: "Email", 
                            controller: email,
                            readOnly: true,
                          ),
                          const _Divider(),
                          _InputField(label: "Phone", controller: phone),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "SAVE CHANGES",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 220),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.border);
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label, 
    required this.controller,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            readOnly: readOnly,
            style: TextStyle(
              color: readOnly ? AppColors.muted : AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  const _BottomSheetOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bg.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDanger ? Colors.redAccent : AppColors.accent,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isDanger ? Colors.redAccent : AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
