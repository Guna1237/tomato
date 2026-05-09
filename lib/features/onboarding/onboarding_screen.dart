import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/tomato_logo.dart';
import '../../shared/widgets/tomato_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TomatoLogo(size: 36),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.metaSemibold(color: AppColors.lavenderGrey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: PageView(
                controller: _ctrl,
                onPageChanged: (p) => setState(() => _page = p),
                children: const [
                  _OnboardSlide1(),
                  _OnboardSlide2(),
                  _OnboardSlide3(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _page == i ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _page == i
                              ? AppColors.punchRed
                              : AppColors.lavenderGrey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(Sp.rpill),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TomatoButton(
                    label: _page < 2 ? 'Continue' : 'Get started',
                    isFullWidth: true,
                    size: TomatoButtonSize.lg,
                    onTap: () {
                      if (_page < 2) {
                        _ctrl.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide1 extends StatefulWidget {
  const _OnboardSlide1();

  @override
  State<_OnboardSlide1> createState() => _OnboardSlide1State();
}

class _OnboardSlide1State extends State<_OnboardSlide1>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _progress = CurvedAnimation(
      parent: _ctrl,
      curve: const Cubic(0.22, 1, 0.36, 1),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _NodePathPainter(
                progress: _progress,
                isDark: isDark,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Someone nearby is already going that way',
            style: AppTextStyles.h1(
              color: isDark ? AppColors.platinum : AppColors.spaceIndigo,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Tomato connects you with verified students already near the pickup point.',
            style: AppTextStyles.body(color: AppColors.lavenderGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NodePathPainter extends CustomPainter {
  final Animation<double> progress;
  final bool isDark;

  _NodePathPainter({required this.progress, required this.isDark})
      : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Two node positions
    final nodeA = Offset(cx - 80, cy - 40);
    final nodeB = Offset(cx + 80, cy + 40);

    // Bezier path between nodes
    final path = Path()
      ..moveTo(nodeA.dx, nodeA.dy)
      ..cubicTo(
        nodeA.dx + 40, nodeA.dy + 60,
        nodeB.dx - 40, nodeB.dy - 60,
        nodeB.dx, nodeB.dy,
      );

    // Draw background dashed path
    final dashedPaint = Paint()
      ..color = AppColors.lavenderGrey.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    _drawDashed(canvas, path, dashedPaint, 6, 5);

    // Animate colored path
    final t = progress.value;
    if (t > 0) {
      final metrics = path.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final animPath = metric.extractPath(0, metric.length * t);
        final brandPaint = Paint()
          ..color = AppColors.punchRed
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(animPath, brandPaint);

        // Moving dot
        final tangent = metric.getTangentForOffset(metric.length * t);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 7, Paint()..color = AppColors.punchRed);
          canvas.drawCircle(
              tangent.position, 5, Paint()..color = Colors.white);
        }
      }
    }

    // Node circles
    final nodePaint = Paint()
      ..color = isDark ? AppColors.darkElevated : AppColors.bgSurface
      ..style = PaintingStyle.fill;
    final nodeStroke = Paint()
      ..color = AppColors.punchRed.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final node in [nodeA, nodeB]) {
      canvas.drawCircle(node, 22, nodePaint);
      canvas.drawCircle(node, 22, nodeStroke);
    }

    // Node icons (simple text)
    const textStyle = TextStyle(
      fontSize: 16,
      color: AppColors.punchRed,
    );
    _drawText(canvas, '📦', nodeA - const Offset(10, 10), textStyle);
    _drawText(canvas, '🏠', nodeB - const Offset(10, 10), textStyle);
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

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_NodePathPainter old) =>
      old.isDark != isDark || old.progress != progress;
}

class _OnboardSlide2 extends StatelessWidget {
  const _OnboardSlide2();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6A55), Color(0xFFEF233C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.punchRed.withValues(alpha: 0.3),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 64,
                ),
              ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your tomatos, your community',
            style: AppTextStyles.h1(
              color: isDark ? AppColors.platinum : AppColors.spaceIndigo,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Earn tomatos by helping others. Spend them when you need a hand. No money, just collaboration.',
            style: AppTextStyles.body(color: AppColors.lavenderGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OnboardSlide3 extends StatelessWidget {
  const _OnboardSlide3();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.punchRed.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B2D42), Color(0xFF3F4359)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.white,
                      size: 56,
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.leaf500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Only verified students',
            style: AppTextStyles.h1(
              color: isDark ? AppColors.platinum : AppColors.spaceIndigo,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Every person on Tomato is verified with their university email and roll number. Trust is built in.',
            style: AppTextStyles.body(color: AppColors.lavenderGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
