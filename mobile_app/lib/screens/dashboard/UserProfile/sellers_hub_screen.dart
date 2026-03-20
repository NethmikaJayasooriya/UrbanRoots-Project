import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class SellersHubScreen extends StatelessWidget {
  const SellersHubScreen({super.key});

  void _toast(BuildContext context, String msg) {
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
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      title: "UrbanRoots Seller Hub",
                      onClose: () => Navigator.of(context).maybePop(),
                      onHelp: () => _toast(context, "Help tapped"),
                    ),

                    const SizedBox(height: 16),

                    // Hero card
                    _HeroCard(
                      title: "Grow your business\nwith UrbanRoots",
                      subtitle:
                          "Join our exclusive community of local plant enthusiasts and botanical experts.",
                      buttonText: "Get Started",
                      onPressed: () => _toast(context, "Get Started tapped"),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      "Onboarding Progress",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _Card(
                      child: Column(
                        children: const [
                          _ProgressRow(
                            state: _ProgressState.done,
                            title: "Identity Verification",
                            subtitle: "Completed",
                          ),
                          _DividerLine(),
                          _ProgressRow(
                            state: _ProgressState.active,
                            title: "Shop Details",
                            subtitle: "In Progress — Tell us about your plants",
                          ),
                          _DividerLine(),
                          _ProgressRow(
                            state: _ProgressState.locked,
                            title: "Payout Method",
                            subtitle: "Locked until shop details are verified",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      "Why sell here?",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const _ReasonCard(
                      icon: Icons.people_alt_rounded,
                      title: "Reach Local Buyers",
                      body:
                          "Connect with thousands of plant lovers in your immediate neighborhood.",
                    ),
                    const SizedBox(height: 12),
                    const _ReasonCard(
                      icon: Icons.auto_awesome_rounded,
                      title: "AI-Powered Pricing",
                      body:
                          "Our smart engine suggests the best price based on rarity and health.",
                    ),
                    const SizedBox(height: 12),
                    const _ReasonCard(
                      icon: Icons.spa_rounded,
                      title: "Care-as-a-Service",
                      body:
                          "Automated plant care reminders for your buyers to ensure success.",
                    ),

                    const SizedBox(height: 28),
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

/* -------------------- Top Bar -------------------- */

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onClose,
    required this.onHelp,
  });

  final String title;
  final VoidCallback onClose;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkResponse(
          onTap: onClose,
          radius: 26,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.close_rounded, color: AppColors.muted, size: 22),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkResponse(
          onTap: onHelp,
          radius: 26,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.help_outline_rounded,
              color: AppColors.muted,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

/* -------------------- Hero -------------------- */

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        // Subtle "leafy" feel without images
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.card, AppColors.bg.withAlpha(120)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.08,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.subText,
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------- Cards -------------------- */

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: AppColors.border);
  }
}

/* -------------------- Onboarding Progress -------------------- */

enum _ProgressState { done, active, locked }

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.state,
    required this.title,
    required this.subtitle,
  });

  final _ProgressState state;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = (state == _ProgressState.locked)
        ? AppColors.muted
        : AppColors.accent;

    final IconData icon = switch (state) {
      _ProgressState.done => Icons.check_rounded,
      _ProgressState.active => Icons.radio_button_checked_rounded,
      _ProgressState.locked => Icons.lock_outline_rounded,
    };

    final Color subtitleColor = (state == _ProgressState.done)
        ? AppColors.accent
        : (state == _ProgressState.locked
              ? AppColors.muted
              : AppColors.subText);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.bg.withAlpha(55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12.2,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------- Why Sell Here -------------------- */

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bg.withAlpha(55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.subText,
                    fontSize: 12.4,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
