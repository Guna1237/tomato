import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/notifications_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../data/models/app_notification.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Deliveries', 'Tomatos', 'Community'];

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  List<AppNotification> _applyFilter(List<AppNotification> notifications) {
    if (_selectedFilter == 'All') return notifications;
    final filterType = switch (_selectedFilter) {
      'Deliveries' => 'delivery',
      'Tomatos'    => 'credit',
      'Community'  => 'community',
      _            => null,
    };
    if (filterType == null) return notifications;
    return notifications.where((n) => n.type == filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final notificationsAsync = ref.watch(notificationsProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 20, 12),
            child: Row(
              children: [
                BackButton(
                  color: fg1,
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.all(12)),
                    minimumSize: WidgetStateProperty.all(const Size(40, 40)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Expanded(child: Text('Inbox', style: AppTextStyles.h1(color: fg1))),
                TextButton(
                  onPressed: currentUserId == null
                      ? null
                      : () async {
                          await NotificationRepository.markAllAsRead(currentUserId);
                        },
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
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (allNotifications) {
                final notifications = _applyFilter(allNotifications);

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_none_rounded,
                            size: 56, color: AppColors.lavenderGrey),
                        const SizedBox(height: 12),
                        Text(
                          "You're all caught up",
                          style: AppTextStyles.bodySm(color: AppColors.lavenderGrey),
                        ),
                      ],
                    ),
                  );
                }

                // Group by day
                final grouped = <String, List<AppNotification>>{};
                final dayOrder = <String>[];
                for (final n in notifications) {
                  final label = _dayLabel(n.createdAt);
                  if (!grouped.containsKey(label)) {
                    dayOrder.add(label);
                    grouped[label] = [];
                  }
                  grouped[label]!.add(n);
                }

                int itemIndex = 0;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  children: [
                    for (final day in dayOrder) ...[
                      SectionHeader(title: day),
                      const SizedBox(height: 10),
                      for (final n in grouped[day]!) ...[
                        _NotificationItem(
                          notification: n,
                          index: itemIndex++,
                          onTap: () async {
                            if (!n.isRead) {
                              await NotificationRepository.markAsRead(n.id);
                            }
                          },
                        )
                            .animate(delay: (itemIndex * 50).ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOut),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ],
                );
              },
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
  final VoidCallback onTap;
  const _NotificationItem({required this.notification, required this.index, required this.onTap});

  Color _typeColor(String? type) {
    return switch (type) {
      'delivery'  => AppColors.ember500,
      'credit'    => AppColors.punchRed,
      'community' => AppColors.leaf500,
      'emergency' => AppColors.flagRed,
      _           => AppColors.lavenderGrey,
    };
  }

  String _typeInitial(String? type) {
    return switch (type) {
      'delivery'  => 'D',
      'credit'    => 'T',
      'community' => 'C',
      'emergency' => '!',
      _           => 'i',
    };
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h < 12 ? 'AM' : 'PM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final color = _typeColor(notification.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? bg
              : (isDark
                  ? AppColors.darkElevated
                  : AppColors.punchRed.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(Sp.rxl),
          border: Border(
            left: notification.isRead
                ? BorderSide.none
                : BorderSide(color: color, width: 3),
            top: BorderSide(
              color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42),
            ),
            right: BorderSide(
              color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42),
            ),
            bottom: BorderSide(
              color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42),
            ),
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
                  _typeInitial(notification.type),
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
                          style: AppTextStyles.bodySmSemibold(color: fg1).copyWith(
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification.createdAt),
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
      ),
    );
  }
}
