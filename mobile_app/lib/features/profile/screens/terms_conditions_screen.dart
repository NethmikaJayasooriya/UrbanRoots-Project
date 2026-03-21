import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/api/api_service.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _alreadyAccepted = false;
  String _version = '2026-03-01';
  String? _acceptedAt;

  @override
  void initState() {
    super.initState();
    _loadTermsStatus();
  }

  Future<void> _loadTermsStatus() async {
    try {
      final data = await ApiService.getCurrentTerms();

      if (!mounted) return;

      setState(() {
        _version = (data['version'] ?? '2026-03-01').toString();
        _alreadyAccepted = data['alreadyAccepted'] == true;
        _acceptedAt = data['acceptedAt']?.toString();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load terms: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptTerms() async {
    if (_isSubmitting || _alreadyAccepted) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      final response = await ApiService.acceptTerms(_version);

      if (!mounted) return;

      final acceptance = response['acceptance'];

      setState(() {
        _alreadyAccepted = true;
        _acceptedAt =
            acceptance?['accepted_at']?.toString() ??
            DateTime.now().toIso8601String();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terms accepted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to accept terms: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _formatAcceptedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(dateString).toLocal();
      final year = date.year.toString().padLeft(4, '0');
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$year-$month-$day  $hour:$minute';
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            title: 'Terms & Conditions',
                            onBack: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(height: 18),
                          _MetaText('Last Updated: $_version'),
                          const SizedBox(height: 8),

                          Text(
                            _alreadyAccepted
                                ? 'Already accepted'
                                : 'Accept the terms and conditions',
                            style: TextStyle(
                              color: _alreadyAccepted
                                  ? AppColors.accent
                                  : AppColors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          if (_alreadyAccepted && _acceptedAt != null) ...[
                            const SizedBox(height: 6),
                            _MetaText(
                              'Accepted on: ${_formatAcceptedDate(_acceptedAt)}',
                            ),
                          ],

                          const SizedBox(height: 18),

                          const _SectionTitle('User Agreement'),
                          const SizedBox(height: 10),
                          const _BodyText(
                            'Welcome to UrbanRoots. By accessing or using our mobile application, you agree to comply with and be bound by the following terms and conditions of use.\n\n'
                            'This agreement governs your relationship with the UrbanRoots community and the technical services provided. Users must be at least 13 years of age to create an account and participate in garden management tracking.',
                          ),

                          const SizedBox(height: 22),

                          const _SectionTitle('Privacy Policy Summary'),
                          const SizedBox(height: 10),
                          const _BodyText(
                            'Your privacy is paramount. We collect data regarding your plant growth progress, garden locations (optional), and streak milestones to provide a personalized gardening experience.',
                          ),
                          const SizedBox(height: 12),
                          const _Bullet(
                            text:
                                'We do not sell your personal data to third parties.',
                          ),
                          const _Bullet(
                            text:
                                'Location data is used solely for climate-based plant care recommendations.',
                          ),
                          const _Bullet(
                            text:
                                'Profile information is visible to other users only if you set your profile to "Public".',
                          ),

                          const SizedBox(height: 22),

                          const _SectionTitle('Liability'),
                          const SizedBox(height: 10),
                          const _BodyText(
                            'UrbanRoots provides gardening advice and tracking tools "as is". While we strive for accuracy in our botanical database, we are not responsible for the health of your physical plants or any loss resulting from reliance on app notifications.\n\n'
                            'Users are encouraged to research specific local environmental factors that may affect plant health beyond the general advice provided within the app.',
                          ),

                          const SizedBox(height: 22),

                          const _SectionTitle('Intellectual Property'),
                          const SizedBox(height: 10),
                          const _BodyText(
                            'All content, including icons, logos, and UI designs, are the property of UrbanRoots. Users retain rights to the photos of plants they upload but grant UrbanRoots a license to display them within the community features.',
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _alreadyAccepted)
                          ? null
                          : _acceptTerms,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: AppColors.border,
                        disabledForegroundColor: AppColors.muted,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _isSubmitting
                            ? 'Saving...'
                            : (_alreadyAccepted
                                  ? 'ALREADY ACCEPTED'
                                  : 'ACCEPT TERMS & CONDITIONS'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
              fontSize: 26,
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

class _MetaText extends StatelessWidget {
  const _MetaText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 14,
        height: 1.55,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.subText,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
