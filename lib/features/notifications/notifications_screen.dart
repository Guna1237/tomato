import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../data/mock/mock_notifications.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Deliveries', 'Credits', 'Community'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final grouped = <String, List<AppNotification>>{};
    for (final n in mockNotifications) {
      grouped.putIfAbsent(n.day, () => []).add(n);
    }

    int itemIndex = 0;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Inbox', style: AppTextStyles.h1(color: fg1)),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFFF3D52)
                          : AppColors.punchRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter chip row
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _filters.length,
              itemBuilder: (context, i) {
                final label = _filters[i];
                final isSelected = _selectedFilter == label;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.spaceIndigo
                          : (isDark ? AppColors.darkSurface : Colors.white),
                      borderRadius: BorderRadius.circular(Sp.rpill),
                      boxShadow: isSelected
                          ? null
                          : [
                              BoxShadow(
                                color: isDark
                                    ? const Color(0x33000000)
                                    : const Color(0x0A2B2D42),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? const Color(0xFFC5CCD9)
                                : const Color(0xFF3F4359)),
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 4),

          // Notification list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                for (final day in grouped.keys) ...[
                  SectionHeader(title: day),
                  const SizedBox(height: 10),
                  for (final n in grouped[day]!) ...[
                    _NotificationItem(notification: n, index: itemIndex++)
                        .animate(delay: (itemIndex * 50).ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOut),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final int index;
  const _NotificationItem({required this.notification, required this.index});

  Color _toneColor(NotificationTone tone) {
    return switch (tone) {
      NotificationTone.matched   => AppColors.punchRed,
      NotificationTone.enroute   => AppColors.ember500,
      NotificationTone.delivered => AppColors.leaf500,
      NotificationTone.emergency => AppColors.flagRed,
      NotificationTone.credit    => AppColors.punchRed,
      NotificationTone.info      => AppColors.lavenderGrey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final color = _toneColor(notification.tone);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notification.isRead
            ? bg
            : (isDark
                ? AppColors.darkElevated
                : AppColors.punchRed.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(Sp.rxl),
        border: Border.all(
          color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon box
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                notification.avatarInitials,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.bodySmSemibold(color: fg1),
                      ),
                    ),
                    Text(
                      notification.time,
                      style: AppTextStyles.micro(color: AppColors.lavenderGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notification.body,
                  style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
