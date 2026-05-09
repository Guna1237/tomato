import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/tomato_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const Positioned.fill(child: ColoredBox(color: AppColors.punchRed)),

          // Floating particles
          ..._buildParticles(size),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TomatoMark(size: 120)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOut),
                const SizedBox(height: 20),
                Text(
                  'tomato',
                  style: AppTextStyles.displayXL(color: Colors.white).copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms)
                    .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut),
                const SizedBox(height: 12),
                Text(
                  'somebody is already going that way',
                  style: AppTextStyles.body(color: Colors.white.withValues(alpha: 0.82)),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 600.ms),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Text(
                'MAHINDRA UNIVERSITY',
                style: AppTextStyles.micro(color: Colors.white.withValues(alpha: 0.65)),
              ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles(Size size) {
    final rng = Random(42);
    return List.generate(8, (i) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.7 + size.height * 0.1;
      final particleSize = 3.0 + rng.nextDouble() * 2;
      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: particleSize,
          height: particleSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        )
            .animate(delay: (i * 200).ms, onPlay: (c) => c.repeat())
            .moveY(
              begin: 0,
              end: -60,
              duration: Duration(milliseconds: 2000 + (i % 3) * 1000),
              curve: Curves.easeInOut,
            )
            .fadeOut(delay: 1200.ms, duration: 800.ms),
      );
    });
  }
}
