import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/tomato_card.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../data/models/delivery.dart';

class ActiveDeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final String? runnerName;

  const ActiveDeliveryCard({
    super.key,
    required this.delivery,
    this.runnerName,
  });

  ChipTone get _chipTone {
    switch (delivery.status) {
      case DeliveryStatus.matching:  return ChipTone.matching;
      case DeliveryStatus.accepted:  return ChipTone.neutral;
      case DeliveryStatus.pickedUp:  return ChipTone.enroute;
      case DeliveryStatus.enRoute:   return ChipTone.enroute;
      case DeliveryStatus.delivered: return ChipTone.delivered;
      default:                       return ChipTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final displayName = runnerName ?? 'Your runner';

    return TomatoCard(
      onTap: () => context.go('/tracking?delivery_id=${delivery.id}'),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: displayName, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.bodySmSemibold(color: fg1),
                    ),
                    Text(
                      '${delivery.pickupLocation} → ${delivery.dropoffLocation}',
                      style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                    ),
                  ],
                ),
              ),
              StatusChip(label: delivery.status.label, tone: _chipTone),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.lavenderGrey, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${delivery.pickupLocation}  →  ${delivery.dropoffLocation}',
                  style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (delivery.etaMinutes > 0)
                Text(
                  '~${delivery.etaMinutes} min',
                  style: AppTextStyles.metaSemibold(
                    color: isDark ? const Color(0xFFFF3D52) : AppColors.punchRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x18EDF2F4)
                      : const Color(0x0F2B2D42),
                  borderRadius: BorderRadius.circular(Sp.rpill),
                ),
              ),
              FractionallySizedBox(
                widthFactor: delivery.progressFraction,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.ember500, AppColors.punchRed],
                    ),
                    borderRadius: BorderRadius.circular(Sp.rpill),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(delivery.progressFraction * 100).toInt()}% complete',
                style: AppTextStyles.micro(color: AppColors.lavenderGrey),
              ),
              Text(
                delivery.id.substring(0, 8),
                style: AppTextStyles.micro(color: AppColors.lavenderGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
