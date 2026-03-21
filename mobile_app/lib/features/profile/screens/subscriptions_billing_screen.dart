import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/api/api_service.dart';

class SubscriptionsBillingScreen extends StatefulWidget {
  const SubscriptionsBillingScreen({super.key});

  @override
  State<SubscriptionsBillingScreen> createState() =>
      _SubscriptionsBillingScreenState();
}

class _SubscriptionsBillingScreenState
    extends State<SubscriptionsBillingScreen> {
  String selectedPlan = "monthly";
  bool _isLoadingSubscription = true;
  bool _isSavingSubscription = false;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadSubscription() async {
    try {
      final data = await ApiService.getSubscription();

      if (!mounted) return;

      final plan = (data['selected_plan'] ?? 'monthly').toString();

      setState(() {
        selectedPlan = _normalizePlan(plan);
        _isLoadingSubscription = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingSubscription = false;
      });

      _toast('Failed to load subscription: $e');
    }
  }

  String _normalizePlan(String value) {
    switch (value) {
      case 'weekly':
      case 'monthly':
      case 'annual':
        return value;
      default:
        return 'monthly';
    }
  }

  String _capitalizePlan(String plan) {
    return '${plan[0].toUpperCase()}${plan.substring(1)}';
  }

  Future<void> _selectPlan(String plan) async {
    if (_isSavingSubscription || selectedPlan == plan) return;

    final previousPlan = selectedPlan;

    setState(() {
      selectedPlan = plan;
      _isSavingSubscription = true;
    });

    try {
      await ApiService.updateSubscription(plan);

      if (!mounted) return;

      setState(() {
        _isSavingSubscription = false;
      });

      _toast('${_capitalizePlan(plan)} plan selected');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        selectedPlan = previousPlan;
        _isSavingSubscription = false;
      });

      _toast('Failed to update subscription: $e');
    }
  }

  Future<void> _startProMembership() async {
    if (_isSavingSubscription) return;

    setState(() {
      _isSavingSubscription = true;
    });

    try {
      await ApiService.updateSubscription(selectedPlan);

      if (!mounted) return;

      setState(() {
        _isSavingSubscription = false;
      });

      _toast(
        'Pro membership started with ${_capitalizePlan(selectedPlan)} plan',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSavingSubscription = false;
      });

      _toast('Failed to start Pro membership: $e');
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
            child: _isLoadingSubscription
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            title: "Subscription & Billing",
                            onBack: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Upgrade to UrbanRoots Pro",
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bg.withAlpha(50),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Text(
                                  "PREMIUM",
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _Card(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.star_rounded,
                                      color: AppColors.accent,
                                      size: 18,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "2 free trials remaining",
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Upgrade for unlimited access to advanced cultivation tools.",
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const _CheckLine(
                                  text: "AI Plant Disease Detection",
                                ),
                                const SizedBox(height: 10),
                                const _CheckLine(
                                  text: "Extra Crop Recommendations",
                                ),
                                const SizedBox(height: 10),
                                const _CheckLine(
                                  text: "Customized Character Access",
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSavingSubscription
                                        ? null
                                        : _startProMembership,
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: AppColors.accent,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    child: Text(
                                      _isSavingSubscription
                                          ? "Saving..."
                                          : "Start Pro Membership",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _PlanTile(
                            label: "WEEKLY",
                            price: "\$4.99",
                            suffix: "/7 days",
                            selected: selectedPlan == "weekly",
                            badge: null,
                            onTap: () => _selectPlan("weekly"),
                          ),
                          const SizedBox(height: 12),
                          _PlanTile(
                            label: "MONTHLY",
                            price: "\$12.99",
                            suffix: "/month",
                            selected: selectedPlan == "monthly",
                            badge: "BEST VALUE",
                            onTap: () => _selectPlan("monthly"),
                          ),
                          const SizedBox(height: 12),
                          _PlanTile(
                            label: "ANNUAL",
                            price: "\$99.99",
                            suffix: "/year",
                            selected: selectedPlan == "annual",
                            badge: null,
                            onTap: () => _selectPlan("annual"),
                          ),
                          const SizedBox(height: 26),
                          const Text(
                            "My Cart & Billing",
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
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      color: AppColors.muted,
                                      size: 18,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Active Cart (2 items)",
                                        style: TextStyle(
                                          color: AppColors.text,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const _CartItem(
                                  title: "Organic Fertilizer",
                                  subtitle: "Premium 5kg pack",
                                  price: "\$24.50",
                                  icon: Icons.eco_rounded,
                                ),
                                const SizedBox(height: 12),
                                const _DividerLine(),
                                const SizedBox(height: 12),
                                const _CartItem(
                                  title: "Seed Starter Kit",
                                  subtitle: "24 Biodegradable pots",
                                  price: "\$12.99",
                                  icon: Icons.spa_rounded,
                                ),
                                const SizedBox(height: 14),
                                const _DividerLine(),
                                const SizedBox(height: 14),
                                Row(
                                  children: const [
                                    Expanded(
                                      child: Text(
                                        "Subtotal",
                                        style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "\$37.49",
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _toast("Proceed to checkout"),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: AppColors.accent,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    child: const Text("Proceed to Checkout"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _Card(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            child: InkWell(
                              onTap: () => _toast("Billing history tapped"),
                              borderRadius: BorderRadius.circular(22),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    color: AppColors.muted,
                                    size: 18,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Billing History",
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.muted,
                                  ),
                                ],
                              ),
                            ),
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: child,
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.accent,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12.8,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.label,
    required this.price,
    required this.suffix,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final String label;
  final String price;
  final String suffix;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (badge != null)
              Positioned(
                right: 0,
                top: -22,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            price,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              suffix,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.accent : AppColors.muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String price;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.bg.withAlpha(50),
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Text(
          price,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.border);
  }
}
