import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/tomato_button.dart';
import '../../../data/mock/mock_deliveries.dart';
import 'delivery_stepper.dart';

class TrackingBottomSheet extends StatelessWidget {
  final Delivery delivery;
  const TrackingBottomSheet({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Sp.r2xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.lavenderGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Sp.rpill),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              UserAvatar(name: delivery.runnerName, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(delivery.runnerName, style: AppTextStyles.h4(color: fg1)),
                    Text(
                      '${delivery.pickupLocation} → ${delivery.dropoffLocation}',
                      style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const StatusChip(label: 'En route', tone: ChipTone.enroute),
                  const SizedBox(height: 4),
                  Text(
                    '~${delivery.etaMinutes} min',
                    style: AppTextStyles.metaSemibold(color: AppColors.punchRed),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Divider(height: 1),
          const SizedBox(height: 20),

          const DeliveryStepper(),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: TomatoButton(
                  label: 'Share ETA',
                  variant: TomatoButtonVariant.secondary,
                  leading: const Icon(Icons.share_outlined, size: 16),
                  isFullWidth: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TomatoButton(
                  label: 'Call runner',
                  variant: TomatoButtonVariant.soft,
                  leading: const Icon(Icons.call_outlined, size: 16),
                  isFullWidth: true,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
