import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/admin_provider.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/map_background.dart';
import '../../shared/widgets/tomato_card.dart';
import 'widgets/admin_queue_item.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final statsAsync = ref.watch(adminStatsProvider);
    final queueAsync = ref.watch(adminQueueProvider);

    final dots = List.generate(14, (i) {
      final x = 30 + (i * 27) % 320;
      final y = 30 + (i * 41) % 150;
      final color = i % 3 == 0
          ? AppColors.punchRed
          : i % 3 == 1
              ? AppColors.ember500
              : AppColors.leaf500;
      return (x: x, y: y, color: color);
    });

    final now = DateTime.now();
    final hour = now.hour;
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[now.weekday - 1];
    final timeLabel = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const BackButtonWidget(),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Admin', style: AppTextStyles.h3(color: fg1)),
                        const SizedBox(width: 8),
                        Text('· operations', style: AppTextStyles.h3(color: AppColors.lavenderGrey)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                const StatusChip(label: 'Live', tone: ChipTone.delivered),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                Text(
                  '$dayName $timeLabel',
                  style: AppTextStyles.h1(color: fg1),
                ),
                const SizedBox(height: 20),

                // KPI grid
                statsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => Text('Error: $e',
                      style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                  data: (stats) => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _KpiCard(
                        label: 'Active deliveries',
                        value: '${stats.activeDeliveries}',
                        trend: 'live',
                        color: AppColors.punchRed,
                      ),
                      _KpiCard(
                        label: 'Runners online',
                        value: '${stats.runnersOnline}',
                        trend: 'available',
                        color: AppColors.ember500,
                      ),
                      _KpiCard(
                        label: 'Pending ID review',
                        value: '${stats.pendingVerifications}',
                        trend: stats.pendingVerifications > 0 ? 'needs action' : 'all clear',
                        color: stats.pendingVerifications > 0
                            ? AppColors.ember500
                            : AppColors.leaf500,
                        isPositive: stats.pendingVerifications == 0,
                      ),
                      _KpiCard(
                        label: 'Disputes',
                        value: '${stats.openDisputes}',
                        trend: 'all clear',
                        color: AppColors.lavenderGrey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Live map card
                const SectionHeader(title: 'Live across campus'),
                const SizedBox(height: 12),
                TomatoCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(Sp.rxl)),
                        child: SizedBox(
                          height: 180,
                          child: Stack(
                            children: [
                              const MapBackground(height: 180),
                              ...dots.map((d) {
                                return Positioned(
                                  left: d.x.toDouble(),
                                  top: d.y.toDouble(),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: d.color,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: d.color.withValues(alpha: 0.55),
                                          blurRadius: 6,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            _LegendDot(color: AppColors.punchRed, label: 'Requesting'),
                            SizedBox(width: 16),
                            _LegendDot(color: AppColors.ember500, label: 'En route'),
                            SizedBox(width: 16),
                            _LegendDot(color: AppColors.leaf500, label: 'Delivered'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Queue
                const SectionHeader(title: 'Queue · needs attention'),
                const SizedBox(height: 12),
                queueAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => Text('Error loading queue: $e',
                      style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                  data: (items) {
                    if (items.isEmpty) {
                      return TomatoCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded,
                                color: AppColors.leaf500, size: 20),
                            const SizedBox(width: 10),
                            Text('Queue is clear', style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AdminQueueItemWidget(item: item),
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // AI summary placeholder
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.spaceIndigo.withValues(alpha: 0.35)
                        : AppColors.spaceIndigo.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Sp.rxl),
                    border: Border.all(
                      color: AppColors.spaceIndigo.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.lavenderGrey, size: 16),
                          const SizedBox(width: 8),
                          Text('Operations summary', style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      statsAsync.when(
                        data: (stats) => Text(
                          '${stats.activeDeliveries} active deliveries, ${stats.runnersOnline} runners online. '
                          '${stats.pendingVerifications > 0 ? '${stats.pendingVerifications} identity reviews pending.' : 'No pending reviews.'} '
                          '${stats.openDisputes == 0 ? 'No disputes.' : '${stats.openDisputes} open disputes.'}',
                          style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                        ),
                        loading: () => Text('Loading...', style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                        error: (_, __) => Text('-', style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final Color color;
  final bool isPositive;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.color,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return TomatoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.h1(color: fg1).copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  trend,
                  style: AppTextStyles.micro(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
      ],
    );
  }
}
