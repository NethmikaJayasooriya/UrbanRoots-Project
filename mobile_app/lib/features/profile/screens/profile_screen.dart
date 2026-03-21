import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/api/api_service.dart';

import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'rate_app_screen.dart';
import 'terms_conditions_screen.dart';
import 'help_support_screen.dart';
import 'subscriptions_billing_screen.dart';
import 'sellers_hub_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoadingStreak = true;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadStreak() async {
    try {
      final data = await ApiService.getMyStreak();

      if (!mounted) return;

      setState(() {
        _currentStreak = (data['current_streak'] ?? 0) as int;
        _isLoadingStreak = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingStreak = false;
      });

      _toast('Failed to load streak: $e');
    }
  }

  Future<void> _completeTodayTaskForTesting() async {
    try {
      final data = await ApiService.completeTodayStreak();

      if (!mounted) return;

      setState(() {
        _currentStreak = (data['current_streak'] ?? 0) as int;
      });

      final alreadyCompletedToday =
          (data['alreadyCompletedToday'] ?? false) as bool;

      if (alreadyCompletedToday) {
        _toast('Today is already counted for your streak');
      } else {
        _toast('Streak updated successfully');
      }
    } catch (e) {
      if (!mounted) return;
      _toast('Failed to complete today task: $e');
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),

                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 3),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.muted,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Alex Rivers",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "@alex_urbanroots",
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Expanded(
                          child: _StatCard(
                            value: "12",
                            label: "PLANTS\nGROWING",
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: _StatCard(
                            value: "3",
                            label: "GARDENS\nMANAGED",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: _isLoadingStreak
                                ? "..."
                                : _currentStreak.toString(),
                            label: "STREAK\nDAYS",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeTodayTaskForTesting,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        child: const Text("Complete Today Task (Test)"),
                      ),
                    ),

                    const SizedBox(height: 26),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "ACCOUNT",
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _MenuItem(
                            icon: Icons.storefront_outlined,
                            title: "Sellers Hub",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SellersHubScreen(),
                                ),
                              );
                            },
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
                            icon: Icons.credit_card_outlined,
                            title: "Subscriptions & Billing",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SubscriptionsBillingScreen(),
                                ),
                              );
                            },
                          ),
                          const _MenuDivider(),
                          _MenuItem(
                            icon: Icons.description_outlined,
                            title: "Terms & Conditions",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TermsConditionsScreen(),
                                ),
                              );
                            },
                          ),
                          const _MenuDivider(),
                          _MenuItem(
                            icon: Icons.help_outline,
                            title: "Help & Support",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HelpSupportScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 22,
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
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
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
    return const Divider(height: 1, thickness: 1, color: AppColors.border);
  }
}
