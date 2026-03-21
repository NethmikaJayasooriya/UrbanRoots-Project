import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/api/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _items = [];
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final data = await ApiService.getNotifications();

      if (!mounted) return;

      setState(() {
        _items = data.map<NotificationItem>((n) {
          return NotificationItem(
            id: n['id'],
            section: (n['section'] ?? 'today') == 'yesterday'
                ? NotificationSection.yesterday
                : NotificationSection.today,
            title: n['title'] ?? '',
            message: n['message'] ?? '',
            timeLabel: n['time_label'] ?? '',
            icon: _mapIcon(n['icon_name']),
            iconBg: _mapIconBg(n['icon_name']),
            isUnread: !(n['is_read'] ?? false),
            actionLabel: n['action_label'],
            actionType: n['action_type'] == 'mark_done'
                ? NotificationActionType.markDone
                : null,
          );
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications: $e')),
      );
    }
  }

  IconData _mapIcon(String? iconName) {
    switch (iconName) {
      case 'inventory_2_outlined':
        return Icons.inventory_2_outlined;
      case 'auto_awesome_outlined':
        return Icons.auto_awesome_outlined;
      case 'menu_book_outlined':
        return Icons.menu_book_outlined;
      case 'bolt_outlined':
        return Icons.bolt_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _mapIconBg(String? iconName) {
    switch (iconName) {
      case 'inventory_2_outlined':
        return const Color(0xFF132B35);
      case 'auto_awesome_outlined':
        return const Color(0xFF2B2A14);
      case 'menu_book_outlined':
        return const Color(0xFF122B1D);
      case 'bolt_outlined':
        return const Color(0xFF23183A);
      default:
        return const Color(0xFF132B35);
    }
  }

  Future<void> _markAllRead() async {
    if (isUpdating || _items.isEmpty) return;

    try {
      setState(() => isUpdating = true);

      await ApiService.markAllNotificationsRead();

      if (!mounted) return;
      setState(() {
        _items.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications cleared')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear notifications: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => isUpdating = false);
    }
  }

  Future<void> _removeSingleNotification(NotificationItem item) async {
    if (isUpdating) return;

    try {
      setState(() => isUpdating = true);

      await ApiService.markNotificationRead(item.id);

      if (!mounted) return;
      setState(() {
        _items.removeWhere((n) => n.id == item.id);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update notification: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => isUpdating = false);
    }
  }

  Future<void> _handleAction(NotificationItem item) async {
    if (isUpdating) return;

    if (item.actionType == NotificationActionType.markDone) {
      try {
        setState(() => isUpdating = true);

        await ApiService.markNotificationRead(item.id);

        if (!mounted) return;
        setState(() {
          _items.removeWhere((n) => n.id == item.id);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification removed')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark notification: $e')),
        );
      } finally {
        if (!mounted) return;
        setState(() => isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final today = _items.where((e) => e.section == NotificationSection.today);
    final yesterday = _items.where(
      (e) => e.section == NotificationSection.yesterday,
    );

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
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      onBack: () => Navigator.of(context).maybePop(),
                      onMarkAllRead: _markAllRead,
                      hasNotifications: _items.isNotEmpty,
                    ),
                    const SizedBox(height: 35),

                    if (_items.isEmpty) ...[
                      const SizedBox(height: 80),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.notifications_off_outlined,
                                color: AppColors.muted,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'No notifications',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'You’re all caught up for now.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      if (today.isNotEmpty) ...[
                        const _SectionLabel('TODAY'),
                        const SizedBox(height: 10),
                        _GroupCard(
                          children: today
                              .map(
                                (n) => _GroupRow(
                                  item: n,
                                  onTap: () async {
                                    await _removeSingleNotification(n);
                                  },
                                  onAction: n.actionLabel == null
                                      ? null
                                      : () async {
                                          await _handleAction(n);
                                        },
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
                                  onTap: () async {
                                    await _removeSingleNotification(n);
                                  },
                                  onAction: null,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],

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

class _Header extends StatelessWidget {
  const _Header({
    required this.onBack,
    required this.onMarkAllRead,
    required this.hasNotifications,
  });

  final VoidCallback onBack;
  final Future<void> Function() onMarkAllRead;
  final bool hasNotifications;

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
        if (hasNotifications)
          TextButton(
            onPressed: () async {
              await onMarkAllRead();
            },
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
          Container(height: 1, color: AppColors.border.withOpacity(0.65)),
        );
      }
    }
    return out;
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.item, required this.onTap, this.onAction});

  final NotificationItem item;
  final Future<void> Function() onTap;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await onTap();
      },
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
                      onPressed: () async {
                        await onAction!();
                      },
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
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: () async {
          await onPressed();
        },
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

enum NotificationSection { today, yesterday }

enum NotificationActionType { markDone }

class NotificationItem {
  NotificationItem({
    required this.id,
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

  final String id;
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
