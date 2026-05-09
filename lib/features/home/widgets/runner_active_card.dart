import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/tomato_card.dart';

class RunnerActiveCard extends StatelessWidget {
  final int openJobCount;
  final VoidCallback onTap;

  const RunnerActiveCard({
    super.key,
    required this.openJobCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return TomatoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Sp.s4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.leaf500.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: AppColors.leaf500,
              size: 20,
            ),
          ),
          const SizedBox(width: Sp.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Runner mode on',
                  style: AppTextStyles.bodySmSemibold(color: fg1),
                ),
                Text(
                  '$openJobCount jobs available',
                  style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.lavenderGrey,
          ),
        ],
      ),
    );
  }
}
