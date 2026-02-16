import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          // ✅ Forces phone-like width on web too
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Profile image
                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 3),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.muted,
                          size: 60,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        "LEVEL 4",
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name + edit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Alex Rivers",
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "@alex_urbanroots",
                      style: TextStyle(color: AppColors.muted),
                    ),

                    const SizedBox(height: 14),

                    // Role tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        "Growing Enthusiast",
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Progress card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Growing Explorer",
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                "70% to Level 5",
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: const LinearProgressIndicator(
                              value: 0.7,
                              minHeight: 10,
                              backgroundColor: AppColors.bg,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Stats row
                    Row(
                      children: const [
                        Expanded(
                          child: _StatCard(
                            value: "12",
                            label: "PLANTS\nGROWING",
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: "3",
                            label: "GARDENS\nMANAGED",
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(value: "15", label: "STREAK\nDAYS"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Recent badges title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "RECENT BADGES",
                        style: TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Badges row
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BadgeCircle(
                          icon: Icons.star,
                          label: "First Plant",
                          color: Color(0xFFFFD54F), // yellow
                        ),
                        _BadgeCircle(
                          icon: Icons.flash_on,
                          label: "7-Day Streak",
                          color: Color(0xFF69F0AE), // green
                        ),
                        _BadgeCircle(
                          icon: Icons.public,
                          label: "Eco Friend",
                          color: Color(0xFF82B1FF), // blue
                        ),
                        _BadgeCircle(
                          icon: Icons.lock,
                          label: "Locked",
                          color: Colors.black,
                          locked: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Menu title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "ACCOUNT",
                        style: TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Menu card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _MenuItem(
                            icon: Icons.person_outline,
                            title: "Personal Info",
                            onTap: () =>
                                _toast(context, "Personal Info tapped"),
                          ),
                          const _MenuDivider(),
                          _MenuItem(
                            icon: Icons.notifications_none,
                            title: "Notifications",
                            onTap: () =>
                                _toast(context, "Notifications tapped"),
                          ),
                          const _MenuDivider(),
                          _MenuItem(
                            icon: Icons.settings_outlined,
                            title: "Settings",
                            onTap: () => _toast(context, "Settings tapped"),
                          ),
                          const _MenuDivider(),
                          _MenuItem(
                            icon: Icons.star_border,
                            title: "Rate App",
                            onTap: () => _toast(context, "Rate App tapped"),
                          ),
                          const _MenuDivider(),
                          _MenuItem(
                            icon: Icons.credit_card,
                            title: "Subscriptions & Billing",
                            onTap: () =>
                                _toast(context, "Subscriptions tapped"),
                          ),
                          const _MenuDivider(),
                          _MenuItem(
                            icon: Icons.description_outlined,
                            title: "Terms & Conditions",
                            onTap: () => _toast(context, "Terms tapped"),
                          ),
                          const _MenuDivider(),
                          _MenuItem(
                            icon: Icons.help_outline,
                            title: "Help & Support",
                            onTap: () => _toast(context, "Help tapped"),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _toast(context, "Logout tapped"),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.border),
                          foregroundColor: AppColors.text,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.logout, color: AppColors.muted),
                        label: const Text(
                          "LOGOUT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
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

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool locked;

  const _BadgeCircle({
    required this.icon,
    required this.label,
    required this.color,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: locked ? Colors.black38 : color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: locked ? Colors.black54 : Colors.black),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: AppColors.border);
  }
}
