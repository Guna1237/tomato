import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/tomato_card.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<String> _digits = List.filled(6, '');
  int _secondsLeft = 42;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDigit(String d) {
    final idx = _digits.indexOf('');
    if (idx == -1) return;
    setState(() => _digits[idx] = d);
    if (idx == 5) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) context.go('/profile-setup');
      });
    }
  }

  void _onDelete() {
    final lastFilled = _digits.lastIndexWhere((d) => d.isNotEmpty);
    if (lastFilled >= 0) setState(() => _digits[lastFilled] = '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    const brand = AppColors.punchRed;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [BackButtonWidget()]),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step 2 of 4', style: AppTextStyles.micro(color: brand)),
                  const SizedBox(height: 10),
                  Text('Check your email', style: AppTextStyles.h1(color: fg1)),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit code to\nya2211003010487@mahindrauniversity.edu.in',
                    style: AppTextStyles.body(color: AppColors.lavenderGrey),
                  ),
                  const SizedBox(height: 32),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      final filled = _digits[i].isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 48,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: filled ? brand : (isDark ? const Color(0x12EDF2F4) : const Color(0x122B2D42)),
                            width: filled ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            filled ? _digits[i] : '',
                            style: AppTextStyles.h2(color: fg1).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Resend
                  Row(
                    children: [
                      Text(
                        _secondsLeft > 0
                            ? 'Resend in 0:${_secondsLeft.toString().padLeft(2, '0')}'
                            : 'Didn\'t receive it?',
                        style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                      ),
                      if (_secondsLeft == 0) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => setState(() {
                            _secondsLeft = 42;
                            _startTimer();
                          }),
                          child: Text(
                            'Resend',
                            style: AppTextStyles.metaSemibold(color: brand),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Trust card
                  TomatoCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.leaf500, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Verified email = trusted handoffs. No anonymous access.',
                            style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom numpad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                for (final row in [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                  ['', '0', '⌫'],
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: row.map((d) {
                        if (d.isEmpty) return const Expanded(child: SizedBox());
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => d == '⌫' ? _onDelete() : _onDigit(d),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurface : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? const Color(0x22000000)
                                          : const Color(0x062B2D42),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    d,
                                    style: AppTextStyles.h3(color: fg1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
