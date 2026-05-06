import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/map_background.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../data/mock/mock_admin.dart';
import 'widgets/kpi_card.dart';
import 'widgets/admin_queue_item.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    // Compute 14 dots mathematically
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
                  'Tuesday evening',
                  style: AppTextStyles.h1(color: fg1),
                ),
                const SizedBox(height: 20),

                // KPI grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: mockAdminKpis.map((k) => KpiCard(kpi: k)).toList(),
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
                              // 14 computed dots
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
                ...mockAdminQueue.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AdminQueueItemWidget(item: item),
                  );
                }),
                const SizedBox(height: 24),

                // AI summary
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.spaceIndigo.withValues(alpha: isDark ? 0.4 : 0.06),
                        AppColors.punchRed.withValues(alpha: 0.04),
                      ],
                    ),
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
                          Text('End-of-day sense', style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(mockAiSummary, style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
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
