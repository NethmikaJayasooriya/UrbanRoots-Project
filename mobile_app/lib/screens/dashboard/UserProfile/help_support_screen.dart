import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/api/api_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoadingTickets = true;
  bool _isLoadingFaqs = true;
  List<dynamic> _tickets = [];
  List<dynamic> _faqs = [];
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadTickets(), _loadFaqs()]);
  }

  Future<void> _loadTickets() async {
    try {
      final data = await ApiService.getSupportTickets();

      if (!mounted) return;

      setState(() {
        _tickets = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load support tickets: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingTickets = false;
      });
    }
  }

  Future<void> _loadFaqs() async {
    try {
      final data = await ApiService.getSupportFaqs();

      if (!mounted) return;

      setState(() {
        _faqs = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load FAQs: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingFaqs = false;
      });
    }
  }

  Future<void> _searchFaqs(String value) async {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        if (!mounted) return;

        setState(() {
          _isLoadingFaqs = true;
        });

        final query = value.trim();
        final data = query.isEmpty
            ? await ApiService.getSupportFaqs()
            : await ApiService.searchSupportFaqs(query);

        if (!mounted) return;

        setState(() {
          _faqs = data;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('FAQ search failed: $e')));
      } finally {
        if (!mounted) return;
        setState(() {
          _isLoadingFaqs = false;
        });
      }
    });
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openContactSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _ContactSupportSheet(),
    );

    if (created == true) {
      await _loadTickets();
    }
  }

  void _openFaqDetail(dynamic faq) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        final category = (faq['category'] ?? 'General').toString();
        final question = (faq['question'] ?? '').toString();
        final answer = (faq['answer'] ?? '').toString();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SizedBox(
                    width: 46,
                    child: Divider(thickness: 4, color: AppColors.border),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  question,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  answer,
                  style: const TextStyle(
                    color: AppColors.subText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    try {
      final dt = DateTime.parse(value).toLocal();
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    } catch (_) {
      return value;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.greenAccent;
      case 'in_progress':
        return Colors.orangeAccent;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSearchText = _searchController.text.trim().isNotEmpty;

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
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          _Header(
                            title: "Help & Support",
                            onBack: () => Navigator.of(context).pop(),
                          ),

                          const SizedBox(height: 32),

                          _SearchBar(
                            controller: _searchController,
                            hintText: "Search FAQs, guides...",
                            onChanged: _searchFaqs,
                          ),

                          const SizedBox(height: 24),

                          const _SectionLabel("SEARCH RESULTS"),

                          const SizedBox(height: 16),

                          if (_isLoadingFaqs)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_faqs.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                hasSearchText
                                    ? "No matching help articles found."
                                    : "No help articles available yet.",
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            Column(
                              children: _faqs.map((faq) {
                                final category = (faq['category'] ?? 'General')
                                    .toString();
                                final question = (faq['question'] ?? '')
                                    .toString();
                                final answer = (faq['answer'] ?? '').toString();

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => _openFaqDetail(faq),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.card,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category,
                                            style: const TextStyle(
                                              color: AppColors.accent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            question,
                                            style: const TextStyle(
                                              color: AppColors.text,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            answer,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.subText,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                          const SizedBox(height: 34),

                          const _SectionLabel("SUPPORT CATEGORIES"),

                          const SizedBox(height: 16),

                          _SupportCard(
                            icon: Icons.bolt_rounded,
                            title: "Getting Started",
                            subtitle: "Master the basics of UrbanRoots",
                            onTap: () {
                              _searchController.text = 'Getting Started';
                              _searchFaqs('Getting Started');
                            },
                          ),

                          const SizedBox(height: 18),

                          _SupportCard(
                            icon: Icons.settings_rounded,
                            title: "Troubleshooting",
                            subtitle: "Issues with hardware or app syncing",
                            onTap: () {
                              _searchController.text = 'Troubleshooting';
                              _searchFaqs('Troubleshooting');
                            },
                          ),

                          const SizedBox(height: 18),

                          _SupportCard(
                            icon: Icons.menu_book_rounded,
                            title: "Plant Care Guides",
                            subtitle: "Tips for healthy harvests",
                            onTap: () {
                              _searchController.text = 'Plant Care';
                              _searchFaqs('Plant Care');
                            },
                          ),

                          const SizedBox(height: 36),

                          const _SectionLabel("POPULAR TOPICS"),

                          const SizedBox(height: 18),

                          _TopicBullet(
                            text: "How do I reset my garden sensors?",
                            onTap: () {
                              _searchController.text =
                                  "How do I reset my garden sensors?";
                              _searchFaqs("How do I reset my garden sensors?");
                            },
                          ),

                          const SizedBox(height: 18),

                          _TopicBullet(
                            text: "Connecting UrbanRoots to HomeKit",
                            onTap: () {
                              _searchController.text =
                                  "Connecting UrbanRoots to HomeKit";
                              _searchFaqs("Connecting UrbanRoots to HomeKit");
                            },
                          ),

                          const SizedBox(height: 18),

                          _TopicBullet(
                            text: "Optimal humidity for indoor lettuce",
                            onTap: () {
                              _searchController.text =
                                  "Optimal humidity for indoor lettuce";
                              _searchFaqs(
                                "Optimal humidity for indoor lettuce",
                              );
                            },
                          ),

                          const SizedBox(height: 36),

                          const _SectionLabel("MY RECENT TICKETS"),

                          const SizedBox(height: 18),

                          if (_isLoadingTickets)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_tickets.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text(
                                "No support tickets yet. Tap Contact Us to create your first ticket.",
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            )
                          else
                            Column(
                              children: _tickets.map((ticket) {
                                final status = (ticket['status'] ?? 'open')
                                    .toString();
                                final category =
                                    (ticket['category'] ?? 'General')
                                        .toString();
                                final subject = (ticket['subject'] ?? '')
                                    .toString();
                                final message = (ticket['message'] ?? '')
                                    .toString();
                                final createdAt = _formatDate(
                                  ticket['created_at']?.toString(),
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                subject,
                                                style: const TextStyle(
                                                  color: AppColors.text,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _statusColor(
                                                  status,
                                                ).withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                status.toUpperCase(),
                                                style: TextStyle(
                                                  color: _statusColor(status),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          category,
                                          style: const TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          message,
                                          style: const TextStyle(
                                            color: AppColors.subText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Created: $createdAt",
                                          style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border.withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openContactSheet,
                          icon: const Icon(Icons.mail_rounded, size: 20),
                          label: const Text("Contact Us"),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Available 24/7. Response time: ~2 hours.",
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _ContactSupportSheet extends StatefulWidget {
  const _ContactSupportSheet();

  @override
  State<_ContactSupportSheet> createState() => _ContactSupportSheetState();
}

class _ContactSupportSheetState extends State<_ContactSupportSheet> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedCategory = 'General';
  bool _isSubmitting = false;

  final List<String> _categories = const [
    'General',
    'Getting Started',
    'Troubleshooting',
    'Plant Care',
    'Account',
    'Billing',
  ];

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill subject and message')),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      await ApiService.createSupportTicket(
        category: _selectedCategory,
        subject: subject,
        message: message,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Support ticket submitted')));

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit ticket: $e')));
    } finally {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(
                width: 46,
                child: Divider(thickness: 4, color: AppColors.border),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Contact Support',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Send us your issue and our team will get back to you.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Category',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: AppColors.card,
                  isExpanded: true,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Subject',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _subjectController,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Briefly describe the issue',
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
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Message',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 5,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Tell us more about the problem...',
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
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  _isSubmitting ? 'Submitting...' : 'SUBMIT TICKET',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.hintText,
    required this.onChanged,
    required this.controller,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.muted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bg.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _TopicBullet extends StatelessWidget {
  const _TopicBullet({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
