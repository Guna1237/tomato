import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MapBackground extends StatelessWidget {
  final double? height;

  const MapBackground({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _MapPainter(isDark: isDark),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final bool isDark;
  _MapPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = isDark ? AppColors.darkSunken : const Color(0xFFF0F2F5);
    final roadColor = isDark
        ? const Color(0x2EEDF2F4)
        : const Color(0xFFE2E6EA);
    final buildingColor = isDark
        ? const Color(0x18EDF2F4)
        : const Color(0xFFD6DCE2);
    final treeColor = isDark
        ? const Color(0x1A3FA85B)
        : const Color(0xFFC8E6CC);

    // Background
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    final roadPaint = Paint()
      ..color = roadColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final buildPaint = Paint()
      ..color = buildingColor
      ..style = PaintingStyle.fill;

    final treePaint = Paint()
      ..color = treeColor
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Main horizontal road
    final road1 = Path()
      ..moveTo(0, h * 0.45)
      ..cubicTo(w * 0.3, h * 0.42, w * 0.6, h * 0.48, w, h * 0.43);
    canvas.drawPath(road1, roadPaint);

    // Diagonal road
    final road2 = Path()
      ..moveTo(w * 0.2, 0)
      ..cubicTo(w * 0.25, h * 0.3, w * 0.4, h * 0.5, w * 0.5, h);
    canvas.drawPath(road2, roadPaint);

    // Top-right road
    final road3 = Path()
      ..moveTo(w * 0.6, 0)
      ..lineTo(w * 0.65, h * 0.45);
    canvas.drawPath(road3, roadPaint);

    // Buildings
    final buildings = [
      Rect.fromLTWH(w * 0.05, h * 0.08, w * 0.12, h * 0.16),
      Rect.fromLTWH(w * 0.28, h * 0.05, w * 0.18, h * 0.12),
      Rect.fromLTWH(w * 0.7, h * 0.08, w * 0.22, h * 0.18),
      Rect.fromLTWH(w * 0.06, h * 0.58, w * 0.15, h * 0.20),
      Rect.fromLTWH(w * 0.55, h * 0.55, w * 0.20, h * 0.25),
      Rect.fromLTWH(w * 0.80, h * 0.55, w * 0.14, h * 0.18),
    ];
    for (final b in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(b, const Radius.circular(6)),
        buildPaint,
      );
    }

    // Trees
    final trees = [
      Offset(w * 0.18, h * 0.32),
      Offset(w * 0.42, h * 0.20),
      Offset(w * 0.75, h * 0.35),
      Offset(w * 0.88, h * 0.42),
      Offset(w * 0.30, h * 0.72),
      Offset(w * 0.68, h * 0.82),
    ];
    for (final t in trees) {
      canvas.drawCircle(t, 8, treePaint);
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.isDark != isDark;
}
