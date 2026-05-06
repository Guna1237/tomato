import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/tomato_button.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/location_card.dart';
import 'widgets/size_picker.dart';
import 'widgets/urgency_slider.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Column(
            children: [
              AppStatusBar(dark: isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const BackButtonWidget(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Request a pickup', style: AppTextStyles.h3(color: fg1)),
                          Text('Step 2 of 3', style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Step progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                        height: 3,
                        decoration: BoxDecoration(
                          color: i <= 1
                              ? AppColors.punchRed
                              : AppColors.lavenderGrey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Sp.rpill),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                  children: [
                    const SectionHeader(title: 'Route'),
                    const SizedBox(height: 12),
                    const LocationCard(),
                    const SizedBox(height: 24),

                    const SectionHeader(title: 'Parcel size'),
                    const SizedBox(height: 12),
                    const SizePicker(),
                    const SizedBox(height: 24),

                    const UrgencySlider(),
                    const SizedBox(height: 24),

                    // Notes card
                    TomatoCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notes (optional)', style: AppTextStyles.h4(color: fg1)),
                          const SizedBox(height: 8),
                          Text(
                            'e.g. "I\'m in class till 4. Knock on H4-205."',
                            style: AppTextStyles.body(color: AppColors.lavenderGrey.withValues(alpha: 0.6)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _ChipButton(label: '📷  Photo', onTap: () {}),
                              const SizedBox(width: 8),
                              _ChipButton(label: '🎙  Voice note', onTap: () {}),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Cost estimate card
                    TomatoCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Estimated cost', style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                              const SizedBox(height: 4),
                              Text('₹35 – ₹45 credits', style: AppTextStyles.h3(color: fg1)),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('ETA', style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                              const SizedBox(height: 4),
                              Text('~8 min', style: AppTextStyles.h3(color: AppColors.punchRed)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Sticky bottom bar
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bg.withValues(alpha: 0),
                    bg,
                  ],
                ),
              ),
              child: TomatoButton(
                label: 'Find a helper  →',
                isFullWidth: true,
                size: TomatoButtonSize.lg,
                onTap: () => context.push('/matching'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ChipButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkElevated : AppColors.bgSunken,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
      ),
    );
  }
}
