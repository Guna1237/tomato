import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class BackButtonWidget extends StatelessWidget {
  final bool frosted;
  final Color? backgroundColor;

  const BackButtonWidget({super.key, this.frosted = false, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final bg = backgroundColor ??
        (isDark ? const Color(0x33EDF2F4) : const Color(0xFFFFFFFF));

    return GestureDetector(
      onTap: () => context.canPop() ? context.pop() : context.go('/login'),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : const Color(0x0A2B2D42),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: fg),
      ),
    );
  }
}
