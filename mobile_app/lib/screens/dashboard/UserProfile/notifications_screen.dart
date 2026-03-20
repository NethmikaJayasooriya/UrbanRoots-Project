import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _items = [
    NotificationItem(
      section: NotificationSection.today,
      title: 'Watering Reminder',
      message:
          'Your Monstera Adansonii needs watering. Soil moisture is below 20%.',
      timeLabel: '2H AGO',
      icon: Icons.inventory_2_outlined,
      iconBg: const Color(0xFF132B35),
      isUnread: true,
      actionLabel: 'Done',
      actionType: NotificationActionType.markDone,
    ),
    NotificationItem(
      section: NotificationSection.today,
      title: 'New Achievement!',
      message: "You've reached a 15-day streak!\nKeep those plants thriving.",
      timeLabel: '5H AGO',
      icon: Icons.auto_awesome_outlined,
      iconBg: const Color(0xFF2B2A14),
      isUnread: false,
    ),
    NotificationItem(
      section: NotificationSection.yesterday,
      title: 'Garden Tip',
      message:
          'Check out our new guide on "Winter Care for Indoor Succulents".',
      timeLabel: '1D AGO',
      icon: Icons.menu_book_outlined,
      iconBg: const Color(0xFF122B1D),
      isUnread: false,
    ),
    NotificationItem(
      section: NotificationSection.yesterday,
      title: 'Subscription Renewed',
      message: 'Your monthly Pro subscription was successfully renewed.',
      timeLabel: '1D AGO',
      icon: Icons.bolt_outlined,
      iconBg: const Color(0xFF23183A),
      isUnread: false,
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (final n in _items) {
        n.isUnread = false;
      }
    });
  }

  void _handleAction(NotificationItem item) {
    if (item.actionType == NotificationActionType.markDone) {
      setState(() => item.isUnread = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Marked as done')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _items.where((e) => e.section == NotificationSection.today);
    final yesterday = _items.where(
      (e) => e.section == NotificationSection.yesterday,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter, // ✅ force to top
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                // ✅ MUCH smaller top padding so it starts near top
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      onBack: () => Navigator.of(context).maybePop(),
                      onMarkAllRead: _markAllRead,
                    ),

                    // ✅ smaller gap after header
                    const SizedBox(height: 35),

                    if (today.isNotEmpty) ...[
                      const _SectionLabel('TODAY'),
                      const SizedBox(height: 10),
                      _GroupCard(
                        children: today
                            .map(
                              (n) => _GroupRow(
                                item: n,
                                onTap: () => setState(() => n.isUnread = false),
                                onAction: n.actionLabel == null
                                    ? null
                                    : () => _handleAction(n),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (yesterday.isNotEmpty) ...[
                      const _SectionLabel('YESTERDAY'),
                      const SizedBox(height: 10),
                      _GroupCard(
                        children: yesterday
                            .map(
                              (n) => _GroupRow(
                                item: n,
                                onTap: () => setState(() => n.isUnread = false),
                                onAction: null,
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    // ✅ BIG bottom empty space (so bottom looks free)
                    const SizedBox(height: 220),
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

/* -------------------- Header -------------------- */

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onMarkAllRead});

  final VoidCallback onBack;
  final VoidCallback onMarkAllRead;

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
        const Expanded(
          child: Text(
            'Notifications',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        TextButton(
          onPressed: onMarkAllRead,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          child: const Text(
            'Mark all read',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/* -------------------- Section Label -------------------- */

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

/* -------------------- Group Card -------------------- */

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: _withDividers(children)),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) {
        out.add(
          Container(height: 1, color: AppColors.border.withValues(alpha: 0.65)),
        );
      }
    }
    return out;
  }
}

/* -------------------- Row -------------------- */

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.item, required this.onTap, this.onAction});

  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBox(icon: item.icon, bg: item.iconBg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.timeLabel,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      if (item.isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.message,
                    style: const TextStyle(
                      color: AppColors.subText,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: item.actionLabel!,
                      onPressed: onAction!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.bg});
  final IconData icon;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Icon(icon, color: AppColors.text, size: 22),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.actionBg,
          foregroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }
}

/* -------------------- Data Model -------------------- */

enum NotificationSection { today, yesterday }

enum NotificationActionType { markDone }

class NotificationItem {
  NotificationItem({
    required this.section,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.iconBg,
    this.isUnread = false,
    this.actionLabel,
    this.actionType,
  });

  final NotificationSection section;
  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final Color iconBg;

  bool isUnread;

  final String? actionLabel;
  final NotificationActionType? actionType;
}
