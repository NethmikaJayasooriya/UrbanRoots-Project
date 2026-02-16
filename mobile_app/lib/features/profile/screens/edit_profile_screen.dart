import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        title: const Text("Edit Profile"),
      ),
      body: const Center(
        child: Text(
          "Edit Profile Screen",
          style: TextStyle(color: AppColors.text),
        ),
      ),
    );
  }
}
