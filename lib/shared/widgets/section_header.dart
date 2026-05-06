import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final fg3 = Theme.of(context).brightness == Brightness.dark
        ? AppColors.lavenderGrey
        : const Color(0xFF5E6781);
    final brand = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFF3D52)
        : AppColors.punchRed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.micro(color: fg3),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.metaSemibold(color: brand),
            ),
          ),
      ],
    );
  }
}
