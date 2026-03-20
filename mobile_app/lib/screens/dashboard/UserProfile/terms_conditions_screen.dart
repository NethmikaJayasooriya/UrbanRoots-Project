import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // Scrollable content
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

                          const _MetaText('Last Updated: March 01, 2026'),

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

                          // breathing space before bottom fixed button area
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),

                // Fixed bottom button area (like your screenshot)
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border.withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'I UNDERSTAND',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
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

/* -------------------- Header (same sizing as other screens) -------------------- */

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

/* -------------------- Typography Widgets -------------------- */

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
