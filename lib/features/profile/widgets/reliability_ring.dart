import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ReliabilityRing extends StatelessWidget {
  final double reliability;
  final double size;

  const ReliabilityRing({super.key, required this.reliability, this.size = 140});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(reliability: reliability, isDark: isDark),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(reliability * 100).toInt()}%',
                style: AppTextStyles.numericMed(
                  color: isDark ? AppColors.platinum : AppColors.spaceIndigo,
                ).copyWith(fontSize: size * 0.22, fontWeight: FontWeight.w800),
              ),
              Text(
                'reliable',
                style: AppTextStyles.micro(color: AppColors.lavenderGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double reliability;
  final bool isDark;

  _RingPainter({required this.reliability, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 8;
    const strokeW = 8.0;

    // Background track
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = isDark ? const Color(0x18EDF2F4) : const Color(0x0F2B2D42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Filled arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -pi / 2,
      reliability * 2 * pi,
      false,
      Paint()
        ..color = AppColors.leaf500
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.reliability != reliability || old.isDark != isDark;
}
