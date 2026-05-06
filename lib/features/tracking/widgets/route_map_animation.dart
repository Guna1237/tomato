import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/map_background.dart';

class RouteMapAnimation extends StatefulWidget {
  const RouteMapAnimation({super.key});

  @override
  State<RouteMapAnimation> createState() => _RouteMapAnimationState();
}

class _RouteMapAnimationState extends State<RouteMapAnimation>
    with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
      lowerBound: 0.4,
      upperBound: 0.85,
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        MapBackground(height: MediaQuery.of(context).size.height),
        AnimatedBuilder(
          animation: Listenable.merge([_progressCtrl, _pulseCtrl]),
          builder: (_, __) => CustomPaint(
            painter: _RoutePainter(
              progress: _progressCtrl.value,
              pulse: _pulseCtrl.value,
              isDark: isDark,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  final double progress;
  final double pulse;
  final bool isDark;

  _RoutePainter({required this.progress, required this.pulse, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Route bezier: gate (bottom) → hostel (top area)
    final routePath = Path()
      ..moveTo(w * 0.22, h * 0.82)
      ..cubicTo(
        w * 0.30, h * 0.65,
        w * 0.55, h * 0.55,
        w * 0.60, h * 0.38,
      )
      ..cubicTo(
        w * 0.65, h * 0.22,
        w * 0.55, h * 0.15,
        w * 0.48, h * 0.12,
      );

    // Dashed reference path
    _drawDashed(
      canvas,
      routePath,
      Paint()
        ..color = AppColors.lavenderGrey.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
      10,
      7,
    );

    // Animated filled portion
    final metrics = routePath.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final filled = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(
        filled,
        Paint()
          ..color = AppColors.punchRed
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      );

      // Runner dot at progress point
      final tangent = metric.getTangentForOffset(metric.length * progress);
      if (tangent != null) {
        final pos = tangent.position;

        // Pulse ring
        canvas.drawCircle(
          pos,
          14 + pulse * 10,
          Paint()
            ..color = AppColors.punchRed.withValues(alpha: (1 - pulse) * 0.3)
            ..style = PaintingStyle.fill,
        );

        // Runner avatar circle
        canvas.drawCircle(pos, 16,
            Paint()..color = Colors.white);
        canvas.drawCircle(pos, 14,
            Paint()..color = const Color(0xFF2C5FA8));

        // 'A' initial
        final tp = TextPainter(
          text: const TextSpan(
            text: 'A',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Origin dot (gate)
    canvas.drawCircle(Offset(w * 0.22, h * 0.82), 8, Paint()..color = AppColors.ember500);
    canvas.drawCircle(Offset(w * 0.22, h * 0.82), 5, Paint()..color = Colors.white);

    // Destination dot (hostel)
    canvas.drawCircle(Offset(w * 0.48, h * 0.12), 10, Paint()..color = AppColors.punchRed);
    canvas.drawCircle(Offset(w * 0.48, h * 0.12), 6, Paint()..color = Colors.white);
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
  bool shouldRepaint(_RoutePainter old) =>
      old.progress != progress || old.pulse != pulse || old.isDark != isDark;
}
