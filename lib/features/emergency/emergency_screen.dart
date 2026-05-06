import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../shared/widgets/tomato_button.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/user_avatar.dart';
import '../../data/mock/mock_runners.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  int _secondsLeft = 4 * 60; // 4 minutes
  Timer? _timer;
  int _selectedRunner = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) { setState(() => _secondsLeft--); }
      else { _timer?.cancel(); }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                BackButtonWidget(),
                SizedBox(width: 14),
                StatusChip(label: 'Re-routing', tone: ChipTone.warn),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                // Pulsing alert icon
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.punchRed.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .scaleXY(begin: 1.0, end: 1.5, duration: 1500.ms, curve: Curves.easeOut)
                          .fadeOut(duration: 1500.ms),
                      Container(
                        width: 52, height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.punchRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Original helper\nunavailable',
                  style: AppTextStyles.h1(color: fg1),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your parcel needs a new runner urgently.',
                  style: AppTextStyles.body(color: AppColors.lavenderGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Urgency card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.punchRed.withValues(alpha: 0.08),
                        AppColors.ember500.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(Sp.rxl),
                    border: Border.all(color: AppColors.punchRed.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.punchRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: AppColors.punchRed, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bonus reward: ₹60 credits', style: AppTextStyles.bodySmSemibold(color: fg1)),
                            Text('Urgent pickup incentive', style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text('Expires in', style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                          Text(_timeDisplay, style: AppTextStyles.h4(color: AppColors.punchRed)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Volunteer avatars
                Row(
                  children: [
                    // Stacked avatars
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: Stack(
                        children: List.generate(3, (i) {
                          return Positioned(
                            left: i * 26.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: bg, width: 2),
                              ),
                              child: UserAvatar(name: mockRunners[i].name, size: 36),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+5 volunteers available',
                      style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Runner options
                ...List.generate(2, (i) {
                  final runner = mockRunners[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRunner = i),
                      child: TomatoCard(
                        isSelected: _selectedRunner == i,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            UserAvatar(name: runner.name, size: 44),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(runner.name, style: AppTextStyles.bodySmSemibold(color: fg1)),
                                  Text(
                                    '${runner.etaMinutes} min · ${(runner.reliability * 100).toInt()}% reliable',
                                    style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                                  ),
                                ],
                              ),
                            ),
                            if (i == 0)
                              const StatusChip(label: 'Fastest', tone: ChipTone.enroute),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),
                TomatoButton(
                  label: 'Accept ${mockRunners[_selectedRunner].name.split(' ').first} · ₹60',
                  isFullWidth: true,
                  size: TomatoButtonSize.lg,
                  onTap: () => context.go('/tracking'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
