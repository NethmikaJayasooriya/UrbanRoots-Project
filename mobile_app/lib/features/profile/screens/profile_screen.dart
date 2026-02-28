import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'rate_app_screen.dart';

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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Profile image
                    Container(
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

                    const SizedBox(height: 18),

                    // Name
                    const Text(
                      "Alex Rivers",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "@alex_urbanroots",
                      style: TextStyle(color: AppColors.muted),
                    ),

                    const SizedBox(height: 18),

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

                    const SizedBox(height: 22),

                    // ACCOUNT title
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
                          // Sellers Hub
                          _MenuItem(
                            icon: Icons.storefront_outlined,
                            title: "Sellers Hub",
                            onTap: () {},
                          ),

                          const _MenuDivider(),

                          _MenuItem(
                            icon: Icons.notifications_none,
                            title: "Notifications",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            },
                          ),

                          const _MenuDivider(),

                          _MenuItem(
                            icon: Icons.settings_outlined,
                            title: "Settings",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),

                          const _MenuDivider(),

                          _MenuItem(
                            icon: Icons.star_outline,
                            title: "Rate App",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RateAppScreen(),
                                ),
                              );
                            },
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

                    const SizedBox(height: 30),
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
