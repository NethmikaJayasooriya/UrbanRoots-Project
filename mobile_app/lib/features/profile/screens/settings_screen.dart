import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import 'edit_profile_screen.dart';
import 'privacy_data_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkTheme = true;
  bool smartReminders = true;

  String measurementUnit = "Metric";

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                    _Header(
                      title: "Settings",
                      onBack: () => Navigator.of(context).maybePop(),
                    ),

                    const SizedBox(height: 30),

                    const _SectionLabel("ACCOUNT & PRIVACY"),
                    const SizedBox(height: 12),
                    _GroupCard(
                      children: [
                        _NavRow(
                          icon: Icons.person_outline_rounded,
                          title: "Personal Info",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const _DividerLine(),
                        _NavRow(
                          icon: Icons.lock_outline_rounded,
                          title: "Privacy & Data",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyDataScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const _SectionLabel("APP PREFERENCES"),
                    const SizedBox(height: 12),
                    _GroupCard(
                      children: [
                        _SwitchRow(
                          icon: Icons.dark_mode_outlined,
                          title: "Dark Theme",
                          value: darkTheme,
                          onChanged: (v) => setState(() => darkTheme = v),
                        ),
                        const _DividerLine(),
                        _ValueRow(
                          icon: Icons.straighten_outlined,
                          title: "Measurement Units",
                          value: measurementUnit,
                          onTap: _openMeasurementSheet,
                        ),
                        const _DividerLine(),
                        _SwitchRow(
                          icon: Icons.notifications_active_outlined,
                          title: "Smart Reminders",
                          value: smartReminders,
                          onChanged: (v) => setState(() => smartReminders = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    _LogoutButton(onTap: () => _toast("Logout tapped")),

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

  void _openMeasurementSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetCard(
        title: "Measurement Units",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetOption(
              title: "Metric",
              selected: measurementUnit == "Metric",
              onTap: () {
                setState(() => measurementUnit = "Metric");
                Navigator.pop(context);
              },
            ),
            const _SheetDivider(),
            _SheetOption(
              title: "Imperial",
              selected: measurementUnit == "Imperial",
              onTap: () {
                setState(() => measurementUnit = "Imperial");
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
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
              color: AppColors.accent,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.border.withOpacity(0.65));
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            _LeftIcon(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.15,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            _LeftIcon(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.15,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.inactiveTrackColor,
    this.inactiveThumbColor,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? inactiveTrackColor;
  final Color? inactiveThumbColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          _LeftIcon(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.15,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: inactiveTrackColor ?? AppColors.border,
            inactiveThumbColor: inactiveThumbColor ?? Colors.white,
          ),
        ],
      ),
    );
  }
}

class _LeftIcon extends StatelessWidget {
  const _LeftIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Icon(icon, color: AppColors.accent, size: 20),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.accent, size: 20),
            SizedBox(width: 10),
            Text(
              "LOGOUT",
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetCard extends StatelessWidget {
  const _BottomSheetCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.accent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.65),
    );
  }
}
