import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/tomato_button.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../data/mock/mock_runners.dart';

class RunnerOfferSheet extends StatelessWidget {
  const RunnerOfferSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final runner = mockSelectedRunner;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Sp.r2xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.lavenderGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Sp.rpill),
            ),
          ),
          const SizedBox(height: 20),

          // Runner info
          Row(
            children: [
              UserAvatar(name: runner.name, size: 52, showRing: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(runner.name, style: AppTextStyles.h3(color: fg1)),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, color: AppColors.punchRed, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(runner.reliability * 100).toInt()}% reliability · ${runner.deliveries} deliveries',
                      style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.punchRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  runner.isNearGate ? 'Near gate' : '${runner.distanceKm}km',
                  style: AppTextStyles.metaSemibold(color: AppColors.punchRed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats row
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSunken : AppColors.bgSunken,
              borderRadius: BorderRadius.circular(Sp.rmd),
            ),
            child: Row(
              children: [
                _StatCell(label: 'ETA', value: '~${runner.etaMinutes} min'),
                _Divider(),
                _StatCell(label: 'Distance', value: '${runner.distanceKm}km'),
                _Divider(),
                _StatCell(label: 'Reward', value: '🍅${runner.rewardCredits}', highlight: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: TomatoButton(
                  label: 'Skip',
                  variant: TomatoButtonVariant.secondary,
                  isFullWidth: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TomatoButton(
                  label: 'Accept ${runner.name.split(' ').first}',
                  isFullWidth: true,
                  size: TomatoButtonSize.lg,
                  onTap: () => context.go('/tracking'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatCell({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.h4(
                color: highlight ? AppColors.punchRed : (
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.platinum
                      : AppColors.spaceIndigo
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 40,
      color: isDark ? const Color(0x12EDF2F4) : const Color(0x122B2D42),
    );
  }
}
