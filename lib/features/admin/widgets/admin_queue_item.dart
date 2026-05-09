import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../shared/widgets/tomato_card.dart';

class AdminQueueItemWidget extends StatelessWidget {
  final AdminQueueEntry item;
  const AdminQueueItemWidget({super.key, required this.item});

  Color get _statusColor => item.isUrgent ? AppColors.ember500 : AppColors.lavenderGrey;

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
              color: _statusColor,
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
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Sp.rpill),
            ),
            child: Text(
              item.status,
              style: AppTextStyles.micro(color: _statusColor),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.lavenderGrey, size: 13),
        ],
      ),
    );
  }
}
