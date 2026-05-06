import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MatchGraphAnimation extends StatefulWidget {
  const MatchGraphAnimation({super.key});

  @override
  State<MatchGraphAnimation> createState() => _MatchGraphAnimationState();
}

class _MatchGraphAnimationState extends State<MatchGraphAnimation>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _pathCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _pathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _pathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: Listenable.merge([_ringCtrl, _pathCtrl]),
      builder: (_, __) => CustomPaint(
        painter: _GraphPainter(
          ringValue: _ringCtrl.value,
          pathValue: _pathCtrl.value,
          isDark: isDark,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final double ringValue;
  final double pathValue;
  final bool isDark;

  _GraphPainter({
    required this.ringValue,
    required this.pathValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    const brand = AppColors.punchRed;

    // 3 expanding rings
    for (int i = 0; i < 3; i++) {
      final t = ((ringValue + i * 0.333) % 1.0);
      final r = 55.0 + t * 75.0;
      final opacity = (1 - t) * 0.55;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = brand.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Center node (user)
    final centerNodePaint = Paint()
      ..color = brand
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 24, Paint()..color = brand.withValues(alpha: 0.12));
    canvas.drawCircle(center, 16, centerNodePaint);

    // 4 candidate runner nodes
    final nodePositions = [
      Offset(cx - 110, cy - 55),  // Priya (top-left)
      Offset(cx + 100, cy - 70),  // Aryan (top-right)
      Offset(cx - 80, cy + 90),   // Kiran (bottom-left)
      Offset(cx + 90, cy + 75),   // Sneha (bottom-right)
    ];
    final nodeColors = [
      const Color(0xFF8C2CA8),
      const Color(0xFF2C5FA8),
      const Color(0xFF2CA868),
      const Color(0xFFA86A2C),
    ];
    final nodeNames = ['P', 'A', 'K', 'S'];

    final nodeSurface = isDark ? AppColors.darkSurface : Colors.white;

    for (int i = 0; i < nodePositions.length; i++) {
      final pos = nodePositions[i];
      final color = nodeColors[i];

      // Dashed path from node to center
      final path = Path()
        ..moveTo(pos.dx, pos.dy)
        ..quadraticBezierTo(
          (pos.dx + center.dx) / 2 + (i.isEven ? -20 : 20),
          (pos.dy + center.dy) / 2 + (i < 2 ? -30 : 30),
          center.dx,
          center.dy,
        );
      _drawDashed(
        canvas,
        path,
        Paint()
          ..color = AppColors.lavenderGrey.withValues(alpha: i == 0 ? 0.5 : 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 0 ? 2 : 1.5
          ..strokeCap = StrokeCap.round,
        8,
        6,
      );

      // For node 0 (Priya, selected): animated brand path
      if (i == 0) {
        final metrics = path.computeMetrics().toList();
        if (metrics.isNotEmpty) {
          final metric = metrics.first;
          final t = pathValue;
          if (t > 0.02) {
            final extracted = metric.extractPath(0, metric.length * t);
            canvas.drawPath(
              extracted,
              Paint()
                ..color = brand
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.5
                ..strokeCap = StrokeCap.round,
            );
          }
          // Moving dot
          final tangent = metric.getTangentForOffset(metric.length * t);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 6, Paint()..color = brand);
            canvas.drawCircle(tangent.position, 4, Paint()..color = Colors.white);
          }
        }
      }

      // Node circle
      canvas.drawCircle(pos, 22, Paint()..color = nodeSurface);
      canvas.drawCircle(
        pos,
        22,
        Paint()
          ..color = color.withValues(alpha: i == 0 ? 0.6 : 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 0 ? 2 : 1,
      );

      // Initials text
      final tp = TextPainter(
        text: TextSpan(
          text: nodeNames[i],
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint, double dash, double gap) {
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final end = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_GraphPainter old) =>
      old.ringValue != ringValue ||
      old.pathValue != pathValue ||
      old.isDark != isDark;
}
