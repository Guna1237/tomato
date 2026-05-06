import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/tomato_card.dart';

class WalletStatsRow extends StatelessWidget {
  const WalletStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _StatCard(label: 'Earned', value: '₹520', color: AppColors.leaf500),
        SizedBox(width: 10),
        _StatCard(label: 'Spent', value: '₹180', color: AppColors.punchRed),
        SizedBox(width: 10),
        _StatCard(label: 'Helped', value: '47', color: AppColors.ember500),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Expanded(
      child: TomatoCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.trending_up_rounded, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.h3(color: fg1)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
          ],
        ),
      ),
    );
  }
}
