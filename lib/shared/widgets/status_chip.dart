import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum ChipTone { matching, enroute, delivered, idle, warn, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final ChipTone tone;
  final bool showDot;

  const StatusChip({
    super.key,
    required this.label,
    this.tone = ChipTone.neutral,
    this.showDot = true,
  });

  (Color, Color) _colors(bool isDark) {
    return switch (tone) {
      ChipTone.matching  => (const Color(0x1AEF233C), AppColors.punchRed),
      ChipTone.enroute   => (const Color(0x1AFF6A55), AppColors.ember500),
      ChipTone.delivered => (const Color(0x1A3FA85B), AppColors.leaf500),
      ChipTone.idle      => (const Color(0x0A8D99AE), AppColors.lavenderGrey),
      ChipTone.warn      => (const Color(0x1AD90429), AppColors.flagRed),
      ChipTone.neutral   => (
          isDark ? const Color(0x1AEDF2F4) : const Color(0x0A2B2D42),
          isDark ? AppColors.platinum : AppColors.spaceIndigo,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (bg, fg) = _colors(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(label, style: AppTextStyles.micro(color: fg)),
        ],
      ),
    );
  }
}
