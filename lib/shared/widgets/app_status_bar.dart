import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppStatusBar extends StatelessWidget {
  final bool dark;
  const AppStatusBar({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final fg = dark ? AppColors.platinum : AppColors.spaceIndigo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('9:41', style: AppTextStyles.metaSemibold(color: fg)),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 16, color: fg),
              const SizedBox(width: 4),
              Icon(Icons.wifi, size: 16, color: fg),
              const SizedBox(width: 4),
              Icon(Icons.battery_full, size: 16, color: fg),
            ],
          ),
        ],
      ),
    );
  }
}
