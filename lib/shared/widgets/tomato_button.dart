import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum TomatoButtonVariant { primary, secondary, soft, ghost, outline }
enum TomatoButtonSize { sm, md, lg }

class TomatoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final TomatoButtonVariant variant;
  final TomatoButtonSize size;
  final bool isFullWidth;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;

  const TomatoButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = TomatoButtonVariant.primary,
    this.size = TomatoButtonSize.md,
    this.isFullWidth = false,
    this.leading,
    this.trailing,
    this.isLoading = false,
  });

  @override
  State<TomatoButton> createState() => _TomatoButtonState();
}

class _TomatoButtonState extends State<TomatoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? const Color(0xFFFF3D52) : AppColors.punchRed;

    final (bg, fg, border) = switch (widget.variant) {
      TomatoButtonVariant.primary   => (brand, Colors.white, Colors.transparent),
      TomatoButtonVariant.secondary => (
          isDark ? AppColors.darkElevated : AppColors.bgSurface,
          isDark ? AppColors.platinum : AppColors.spaceIndigo,
          isDark ? const Color(0x12EDF2F4) : const Color(0x122B2D42),
        ),
      TomatoButtonVariant.soft => (
          brand.withValues(alpha: 0.12),
          brand,
          Colors.transparent,
        ),
      TomatoButtonVariant.ghost => (
          Colors.transparent,
          isDark ? AppColors.platinum : AppColors.spaceIndigo,
          Colors.transparent,
        ),
      TomatoButtonVariant.outline => (
          Colors.transparent,
          brand,
          brand,
        ),
    };

    final (height, fontSize, hPad) = switch (widget.size) {
      TomatoButtonSize.sm => (40.0, 13.0, 16.0),
      TomatoButtonSize.md => (52.0, 15.0, 20.0),
      TomatoButtonSize.lg => (60.0, 16.0, 24.0),
    };

    final radius = switch (widget.size) {
      TomatoButtonSize.sm => 14.0,
      TomatoButtonSize.md => 18.0,
      TomatoButtonSize.lg => 20.0,
    };

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          height: height,
          width: widget.isFullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border, width: border == Colors.transparent ? 0 : 1.5),
          ),
          child: Row(
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 8)],
              if (widget.isLoading)
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              else
                Text(
                  widget.label,
                  style: AppTextStyles.bodySmSemibold(color: fg).copyWith(fontSize: fontSize),
                ),
              if (widget.trailing != null) ...[const SizedBox(width: 8), widget.trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
