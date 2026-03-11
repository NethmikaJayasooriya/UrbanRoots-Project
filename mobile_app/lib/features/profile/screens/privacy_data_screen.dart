import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import 'change_password_screen.dart';
import 'download_my_data_screen.dart';

class PrivacyDataScreen extends StatefulWidget {
  const PrivacyDataScreen({super.key});

  @override
  State<PrivacyDataScreen> createState() => _PrivacyDataScreenState();
}

class _PrivacyDataScreenState extends State<PrivacyDataScreen> {
  bool twoStepVerification = false;
  bool personalizedRecommendations = false;
  bool dataSharingWithPartners = false;

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
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      title: "Privacy & Data",
                      onBack: () => Navigator.of(context).maybePop(),
                    ),

                    const SizedBox(height: 34),

                    const _SectionLabel("SECURITY"),
                    const SizedBox(height: 14),

                    _CardGroup(
                      children: [
                        _NavTile(
                          icon: Icons.lock_outline_rounded,
                          title: "Change Password",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                        const _DividerLine(),
                        _SwitchTile(
                          icon: Icons.shield_outlined,
                          title: "Two-Step Verification",
                          subtitle: "Enhanced protection for your account",
                          value: twoStepVerification,
                          onChanged: (v) {
                            setState(() => twoStepVerification = v);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const _SectionLabel("DATA PRIVACY"),
                    const SizedBox(height: 14),

                    _CardGroup(
                      children: [
                        _SwitchTile(
                          icon: Icons.tune_rounded,
                          title: "Personalized Recommendations",
                          subtitle: "Use my data for better plant suggestions",
                          value: personalizedRecommendations,
                          onChanged: (v) {
                            setState(() => personalizedRecommendations = v);
                          },
                        ),
                        const _DividerLine(),
                        _SwitchTile(
                          icon: Icons.share_outlined,
                          title: "Data Sharing with Partners",
                          subtitle: "Allow sharing with nursery partners",
                          value: dataSharingWithPartners,
                          onChanged: (v) {
                            setState(() => dataSharingWithPartners = v);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const _SectionLabel("ACCOUNT MANAGEMENT"),
                    const SizedBox(height: 14),

                    _CardGroup(
                      children: [
                        _NavTile(
                          icon: Icons.download_rounded,
                          title: "Download My Data",
                          subtitle: "Get a copy of your UrbanRoots history",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DownloadMyDataScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _DangerCard(
                      icon: Icons.delete_outline_rounded,
                      title: "Delete Account",
                      subtitle: "This action is permanent and cannot be undone",
                      onTap: () => _toast("Delete Account tapped"),
                    ),

                    const SizedBox(height: 120),

                    Center(
                      child: Column(
                        children: [
                          const Text(
                            "UrbanRoots uses end-to-end encryption for your private\n"
                            "gardening logs and community interactions.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => _toast("Privacy Policy tapped"),
                            child: const Text(
                              "Read Privacy Policy",
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.accent,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
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

class _IconWrap extends StatelessWidget {
  const _IconWrap({required this.icon, this.isDanger = false});

  final IconData icon;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: isDanger
            ? const Color(0xFF5A2A25).withOpacity(0.65)
            : AppColors.actionBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        icon,
        color: isDanger ? const Color(0xFFFF6666) : AppColors.accent,
        size: 30,
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Row(
          children: [
            _IconWrap(icon: icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        children: [
          _IconWrap(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.accent.withOpacity(0.35),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.actionBg,
          ),
        ],
      ),
    );
  }
}

class _DangerCard extends StatelessWidget {
  const _DangerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2B251F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF7A3A36)),
        ),
        child: Row(
          children: [
            _IconWrap(icon: icon, isDanger: true),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFFF6666),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFFF7C7C),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
