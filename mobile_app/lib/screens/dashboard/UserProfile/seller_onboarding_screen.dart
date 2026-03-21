import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/api/api_service.dart';

class SellerOnboardingScreen extends StatefulWidget {
  const SellerOnboardingScreen({super.key});

  @override
  State<SellerOnboardingScreen> createState() =>
      _SellerOnboardingScreenState();
}

class _SellerOnboardingScreenState extends State<SellerOnboardingScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopDescriptionController =
      TextEditingController();

  String _selectedPayoutMethod = 'Bank Transfer';

  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, dynamic>? _seller;

  final List<String> _payoutMethods = const [
    'Bank Transfer',
    'Mobile Wallet',
    'Cash Pickup',
  ];

  @override
  void initState() {
    super.initState();
    _loadSeller();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSeller() async {
    try {
      final data = await ApiService.getSeller();

      if (!mounted) return;

      _seller = data;

      _shopNameController.text = (data?['shop_name'] ?? '').toString();
      _shopDescriptionController.text =
          (data?['shop_description'] ?? '').toString();

      final payoutMethod = (data?['payout_method'] ?? '').toString();
      if (_payoutMethods.contains(payoutMethod)) {
        _selectedPayoutMethod = payoutMethod;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load onboarding data: $e')),
      );
    }
  }

  String get _currentStep {
    return (_seller?['onboarding_step'] ?? 'identity').toString();
  }

  Future<void> _completeIdentity() async {
    if (_isSubmitting) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      final updated = await ApiService.completeSellerIdentity();

      if (!mounted) return;

      setState(() {
        _seller = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identity verification completed')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete identity step: $e')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _saveShopDetails() async {
    if (_isSubmitting) return;

    final shopName = _shopNameController.text.trim();
    final shopDescription = _shopDescriptionController.text.trim();

    if (shopName.isEmpty || shopDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all shop details')),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final updated = await ApiService.updateSellerShop(
        shopName: shopName,
        shopDescription: shopDescription,
      );

      if (!mounted) return;

      setState(() {
        _seller = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop details saved')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save shop details: $e')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _savePayoutMethod() async {
    if (_isSubmitting) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      final updated = await ApiService.setSellerPayout(
        method: _selectedPayoutMethod,
      );

      if (!mounted) return;

      setState(() {
        _seller = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seller onboarding completed')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save payout method: $e')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildStepIndicator() {
    final step = _currentStep;

    int currentIndex;
    if (step == 'identity') {
      currentIndex = 0;
    } else if (step == 'shop') {
      currentIndex = 1;
    } else if (step == 'payout') {
      currentIndex = 2;
    } else {
      currentIndex = 2;
    }

    return Row(
      children: List.generate(3, (index) {
        final isActive = index == currentIndex;
        final isDone = index < currentIndex || _currentStep == 'completed';

        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
            decoration: BoxDecoration(
              color: isDone || isActive
                  ? AppColors.accent
                  : AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkResponse(
                          onTap: () => Navigator.of(context).maybePop(false),
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
                        const Expanded(
                          child: Text(
                            'Seller Onboarding',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildStepIndicator(),

                    const SizedBox(height: 24),

                    if (_currentStep == 'identity') ...[
                      _StepCard(
                        title: 'Step 1: Identity Verification',
                        subtitle:
                            'Confirm your identity to begin selling on UrbanRoots.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'This demo step marks your identity verification as complete and unlocks the next stage.',
                              style: TextStyle(
                                color: AppColors.subText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : _completeIdentity,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  _isSubmitting
                                      ? 'Saving...'
                                      : 'VERIFY IDENTITY',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_currentStep == 'shop') ...[
                      _StepCard(
                        title: 'Step 2: Shop Details',
                        subtitle:
                            'Tell us about your plant store so buyers know what you offer.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _InputLabel('Shop Name'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _shopNameController,
                              style: const TextStyle(color: AppColors.text),
                              decoration: _inputDecoration(
                                hint: 'Enter your shop name',
                              ),
                            ),
                            const SizedBox(height: 18),
                            const _InputLabel('Shop Description'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _shopDescriptionController,
                              maxLines: 4,
                              style: const TextStyle(color: AppColors.text),
                              decoration: _inputDecoration(
                                hint:
                                    'Describe your plants, specialties, and style',
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : _saveShopDetails,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  _isSubmitting
                                      ? 'Saving...'
                                      : 'SAVE SHOP DETAILS',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_currentStep == 'payout' || _currentStep == 'completed') ...[
                      _StepCard(
                        title: 'Step 3: Payout Method',
                        subtitle:
                            'Choose how you want to receive payments from your sales.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _InputLabel('Payout Method'),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPayoutMethod,
                                  dropdownColor: AppColors.card,
                                  isExpanded: true,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: _payoutMethods.map((method) {
                                    return DropdownMenuItem<String>(
                                      value: method,
                                      child: Text(method),
                                    );
                                  }).toList(),
                                  onChanged: _isSubmitting
                                      ? null
                                      : (value) {
                                          if (value == null) return;
                                          setState(() {
                                            _selectedPayoutMethod = value;
                                          });
                                        },
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : _savePayoutMethod,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  _isSubmitting
                                      ? 'Saving...'
                                      : 'COMPLETE SETUP',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.muted),
      filled: true,
      fillColor: AppColors.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.subText,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}