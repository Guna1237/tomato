import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DeliveryStepper extends StatelessWidget {
  const DeliveryStepper({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      ('Picked up', true, false),
      ('En route', true, true),   // current
      ('Arriving soon', false, false),
      ('Delivered', false, false),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final (label, done, current) = steps[i];
        final isLast = i == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot + line
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: done
                        ? AppColors.leaf500
                        : current
                            ? AppColors.punchRed
                            : (isDark ? AppColors.darkElevated : const Color(0xFFE2E6EA)),
                    shape: BoxShape.circle,
                    boxShadow: current
                        ? [
                            BoxShadow(
                              color: AppColors.punchRed.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: done && !current
                      ? const Icon(Icons.check, color: Colors.white, size: 9)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 1.5,
                    height: 32,
                    color: done
                        ? AppColors.leaf500.withValues(alpha: 0.4)
                        : (isDark ? const Color(0x18EDF2F4) : const Color(0x0F2B2D42)),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: EdgeInsets.only(top: 0, bottom: isLast ? 0 : 24),
              child: Text(
                label,
                style: current
                    ? AppTextStyles.bodySmSemibold(color: AppColors.punchRed)
                    : done
                        ? AppTextStyles.bodySm(color: AppColors.lavenderGrey)
                        : AppTextStyles.bodySm(color: AppColors.lavenderGrey.withValues(alpha: 0.5)),
              ),
            ),
          ],
        );
      }),
    );
  }
}
