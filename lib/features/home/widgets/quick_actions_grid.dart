import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Request pickup (red)
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/request'),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.punchRed,
                borderRadius: BorderRadius.circular(Sp.rxl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.punchRed.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.inbox_outlined, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Request',
                          style: AppTextStyles.bodySmSemibold(color: Colors.white),
                        ),
                        Text(
                          'pickup',
                          style: AppTextStyles.meta(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Become a runner (white)
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(Sp.rxl),
                border: Border.all(
                  color: isDark
                      ? const Color(0x12EDF2F4)
                      : const Color(0x0A2B2D42),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_walk_rounded,
                    color: isDark ? AppColors.platinum : AppColors.spaceIndigo,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Be a',
                          style: AppTextStyles.bodySmSemibold(
                            color: isDark ? AppColors.platinum : AppColors.spaceIndigo,
                          ),
                        ),
                        Text(
                          'runner',
                          style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
