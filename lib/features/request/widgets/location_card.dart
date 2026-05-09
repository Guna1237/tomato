import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/tomato_card.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return TomatoCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Connector line
          Column(
            children: [
              Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.punchRed,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 1.5, height: 36,
                color: AppColors.lavenderGrey.withValues(alpha: 0.3),
              ),
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lavenderGrey, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PICKUP FROM', style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                const SizedBox(height: 4),
                Text('Main Gate - Parcel Center', style: AppTextStyles.bodySmSemibold(color: fg1)),
                Divider(height: 20, color: AppColors.lavenderGrey.withValues(alpha: 0.15)),
                Text('DELIVER TO', style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                const SizedBox(height: 4),
                Text('H4 North Wing', style: AppTextStyles.bodySmSemibold(color: fg1)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.punchRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.swap_vert_rounded, color: AppColors.punchRed, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
