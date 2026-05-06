import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class TomatoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? customShadow;

  const TomatoCard({
    super.key,
    required this.child,
    this.padding,
    this.isSelected = false,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.bgSurface);
    final radius = borderRadius ?? Sp.rxl;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: isSelected
            ? Border.all(
                color: isDark ? const Color(0xFFFF3D52) : AppColors.punchRed,
                width: 2,
              )
            : Border.all(
                color: isDark
                    ? const Color(0x12EDF2F4)
                    : const Color(0x0A2B2D42),
                width: 1,
              ),
        boxShadow: customShadow ??
            [
              BoxShadow(
                color: isDark
                    ? const Color(0x33000000)
                    : const Color(0x082B2D42),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: (isDark
                          ? const Color(0xFFFF3D52)
                          : AppColors.punchRed)
                      .withValues(alpha: 0.06),
                  highlightColor: (isDark
                          ? const Color(0xFFFF3D52)
                          : AppColors.punchRed)
                      .withValues(alpha: 0.04),
                  child: Padding(
                    padding: padding ?? const EdgeInsets.all(Sp.s5),
                    child: child,
                  ),
                ),
              )
            : Padding(
                padding: padding ?? const EdgeInsets.all(Sp.s5),
                child: child,
              ),
      ),
    );
  }
}
