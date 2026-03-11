import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasNumber => RegExp(r'\d').hasMatch(_newPasswordController.text);
  bool get _hasSpecialCharacter => RegExp(
    r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]]',
  ).hasMatch(_newPasswordController.text);
  bool get _hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(_newPasswordController.text);

  bool get _passwordsMatch =>
      _newPasswordController.text.isNotEmpty &&
      _newPasswordController.text == _confirmPasswordController.text;

  bool get _canSubmit =>
      _currentPasswordController.text.isNotEmpty &&
      _hasMinLength &&
      _hasNumber &&
      _hasSpecialCharacter &&
      _hasUppercase &&
      _passwordsMatch;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_refresh);
    _confirmPasswordController.addListener(_refresh);
    _currentPasswordController.addListener(_refresh);
  }

  void _refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated successfully.")),
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
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      title: "Change Password",
                      onBack: () => Navigator.of(context).maybePop(),
                    ),

                    const SizedBox(height: 34),

                    const _FieldLabel("Current Password"),
                    const SizedBox(height: 12),
                    _PasswordField(
                      controller: _currentPasswordController,
                      obscureText: !_showCurrentPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _showCurrentPassword = !_showCurrentPassword;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    const _FieldLabel("New Password"),
                    const SizedBox(height: 12),
                    _PasswordField(
                      controller: _newPasswordController,
                      obscureText: !_showNewPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _showNewPassword = !_showNewPassword;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    const _FieldLabel("Confirm New Password"),
                    const SizedBox(height: 12),
                    _PasswordField(
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                    ),

                    const SizedBox(height: 38),

                    _RequirementsCard(
                      children: [
                        _RequirementRow(
                          text: "At least 8 characters long",
                          passed: _hasMinLength,
                        ),
                        const SizedBox(height: 18),
                        _RequirementRow(
                          text: "At least one number (0-9)",
                          passed: _hasNumber,
                        ),
                        const SizedBox(height: 18),
                        _RequirementRow(
                          text: "At least one special character (!@#\$%^&*)",
                          passed: _hasSpecialCharacter,
                        ),
                        const SizedBox(height: 18),
                        _RequirementRow(
                          text: "At least one uppercase letter",
                          passed: _hasUppercase,
                        ),
                        const SizedBox(height: 18),
                        _RequirementRow(
                          text: "Passwords match",
                          passed: _passwordsMatch,
                        ),
                      ],
                    ),

                    const SizedBox(height: 220),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updatePassword,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        child: const Text("Update Password"),
                      ),
                    ),
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

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkResponse(
          onTap: onBack,
          radius: 26,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.text,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF0E8F55), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              obscuringCharacter: '•',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 26,
                letterSpacing: 5,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "••••••••",
                hintStyle: TextStyle(
                  color: Color(0xFF7B88A6),
                  fontSize: 26,
                  letterSpacing: 5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: const Color(0xFF7B88A6),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Password Requirements",
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.text, required this.passed});

  final String text;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: passed ? AppColors.accent : AppColors.actionBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 18,
            color: passed ? Colors.black : AppColors.muted,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: passed ? AppColors.subText : AppColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
