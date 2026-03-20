import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int selectedStars = 0;
  final TextEditingController _commentController = TextEditingController();

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rating submitted ($selectedStars★)")),
    );
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
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER (same size as notifications/settings)
                    Row(
                      children: [
                        InkResponse(
                          onTap: () => Navigator.pop(context),
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
                        const Text(
                          "Rate App",
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 26, // ✅ matched
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Icon Circle
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: AppColors.bg.withOpacity(0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: AppColors.accent,
                              size: 30,
                            ),
                          ),

                          const SizedBox(height: 18),

                          /// Title (Reduced size)
                          const Text(
                            "Enjoying UrbanRoots?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 20, // ✅ reduced
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// Subtitle (Reduced)
                          const Text(
                            "Your feedback helps us grow the best\ncommunity for urban gardeners.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13, // ✅ reduced
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 22),

                          /// Stars (smaller)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              final index = i + 1;
                              return IconButton(
                                splashRadius: 20,
                                iconSize: 34, // ✅ reduced
                                onPressed: () {
                                  setState(() => selectedStars = index);
                                },
                                icon: Icon(
                                  selectedStars >= index
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: AppColors.accent,
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 20),

                          /// Section Label (same as notifications)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "LEAVE A COMMENT (OPTIONAL)",
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// Comment box
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.bg.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: TextField(
                              controller: _commentController,
                              maxLines: 4,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    "Tell us what you love or how we can improve…",
                                hintStyle: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: selectedStars == 0 ? null : _submit,
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
                              ),
                              child: const Text(
                                "Submit Rating",
                                style: TextStyle(
                                  fontSize: 15, // ✅ reduced
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// Maybe Later
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.muted,
                                side: BorderSide(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                "Maybe Later",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Leave bottom free space (like other screens)
                    const SizedBox(height: 240),
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
