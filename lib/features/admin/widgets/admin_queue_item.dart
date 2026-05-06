import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/tomato_card.dart';
import '../../../data/mock/mock_admin.dart';

class AdminQueueItemWidget extends StatelessWidget {
  final AdminQueueItem item;
  const AdminQueueItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return TomatoCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.bodySmSemibold(color: fg1)),
                Text(item.subtitle, style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: item.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Sp.rpill),
            ),
            child: Text(
              item.status,
              style: AppTextStyles.micro(color: item.statusColor),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.lavenderGrey, size: 13),
        ],
      ),
    );
  }
}
