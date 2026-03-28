import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/api/api_service.dart';

import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'rate_app_screen.dart';
import 'terms_conditions_screen.dart';
import 'help_support_screen.dart';
import 'subscriptions_billing_screen.dart';
import 'package:mobile_app/screens/dashboard/UserProfile/sellers_hub_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/services/otp_service.dart';
import '../../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import '../../../services/api_service.dart' as core_api;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/screens/dashboard/Marketplace/cart_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  // GlobalKey lets the nav bar trigger a hard refresh of profile data
  static final GlobalKey<_ProfileScreenState> globalKey = GlobalKey<_ProfileScreenState>();

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoadingStreak = true;
  int _currentStreak = 0;
  String _userName = "Plant Lover";
  String _userEmail = "";
  String? _profileImageUrl;
  bool _isLoadingStats = true;
  int _plantsGrowing = 0;
  int _gardensManaged = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStreak();
    _loadStats();
  }

  /// Called by nav_bar when the user taps the Profile tab.
  void refresh() {
    _loadUser();
    _loadStreak();
    _loadStats();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _userName = user.displayName ?? "Plant Lover";
          _userEmail = user.email ?? "";
          _profileImageUrl = user.photoURL;
        });
      }
      
      try {
        final profile = await ApiService.getProfile();
        if (mounted) {
          setState(() {
            final fName = profile['first_name']?.toString().trim() ?? '';
            final lName = profile['last_name']?.toString().trim() ?? '';
            if (fName.isNotEmpty || lName.isNotEmpty) {
              _userName = "$fName $lName".trim();
            }
            if (profile['profile_image_url'] != null) {
              _profileImageUrl = profile['profile_image_url'];
            }
          });
        }
      } catch (e) {
        // Fallback to Firebase defaults
      }
    }
  }

  void _logout() async {
    if (mounted) {
      context.read<CartModel>().clearCart();
    }
    await FirebaseAuth.instance.signOut();
    await OtpService.setLoggedIn(false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
         backgroundColor: AppColors.card,
         title: const Text("Delete Account", style: TextStyle(color: Colors.white)),
         content: const Text("Are you sure you want to permanently delete your account? This cannot be undone.", style: TextStyle(color: Colors.white70)),
         actions: [
            TextButton(
               onPressed: () => Navigator.pop(ctx),
               child: const Text("Cancel", style: TextStyle(color: AppColors.accent)),
            ),
            TextButton(
               onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                     await FirebaseAuth.instance.currentUser?.delete();
                     _logout();
                  } catch (e) {
                     _toast("Failed to delete account. You may need to sign in again.");
                  }
               },
               child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            ),
         ]
      )
    );
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
      // Handle silently since streaks API is not fully implemented yet
    }
  }

  Future<void> _loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingStats = false);
      return;
    }

    try {
      final String uid = user.uid;
      final int? gardenId = await core_api.ApiService.fetchUserGardenId(uid);
      
      int gardens = 0;
      int plants = 0;
      
      if (gardenId != null) {
        gardens = 1;
        final crops = await core_api.ApiService.getGardenCrops(gardenId);
        if (crops != null) {
          plants = crops.length;
        }
      }

      if (mounted) {
        setState(() {
          _gardensManaged = gardens;
          _plantsGrowing = plants;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  // Streak tracking now runs automatically via background startup routine

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
                        image: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_profileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                          ? const Icon(Icons.person, size: 60, color: AppColors.muted)
                          : null,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                          },
                          child: const Icon(Icons.edit, size: 20, color: AppColors.accent),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _userEmail.isNotEmpty ? _userEmail : "@user",
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: _isLoadingStats ? "..." : _plantsGrowing.toString(),
                            label: "PLANTS\nGROWING",
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _StatCard(
                            value: _isLoadingStats ? "..." : _gardensManaged.toString(),
                            label: "GARDENS\nMANAGED",
                          ),
                        ),
                        const SizedBox(width: 14),
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



                    const SizedBox(height: 36),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "ACCOUNT",
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

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
                          const _MenuDivider(),
                          _MenuItem(
                            icon: Icons.logout,
                            title: "Logout",
                            onTap: _logout,
                          ),
                          const _MenuDivider(),
                          _MenuItem(
                            icon: Icons.delete_forever,
                            title: "Delete Account",
                            onTap: _confirmDeleteAccount,
                            isDanger: true,
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
  final bool isDanger;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        child: Row(
          children: [
            Icon(icon, color: isDanger ? Colors.redAccent : AppColors.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDanger ? Colors.redAccent : AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDanger ? Colors.redAccent.withOpacity(0.5) : AppColors.muted),
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

