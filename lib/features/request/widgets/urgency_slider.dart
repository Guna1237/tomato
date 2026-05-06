import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class UrgencySlider extends StatefulWidget {
  const UrgencySlider({super.key});

  @override
  State<UrgencySlider> createState() => _UrgencySliderState();
}

class _UrgencySliderState extends State<UrgencySlider> {
  double _value = 0.5;

  final _labels = ['15 min', 'Today', 'Tomorrow'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final trackBg = isDark ? const Color(0x18EDF2F4) : const Color(0x0F2B2D42);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Urgency', style: AppTextStyles.h4(color: fg1)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final trackW = constraints.maxWidth;
            final thumbX = _value * (trackW - 28);

            return GestureDetector(
              onHorizontalDragUpdate: (d) {
                setState(() {
                  _value = ((_value * trackW + d.delta.dx) / trackW).clamp(0.0, 1.0);
                });
              },
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Track background
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: trackBg,
                        borderRadius: BorderRadius.circular(Sp.rpill),
                      ),
                    ),
                    // Filled track
                    FractionallySizedBox(
                      widthFactor: _value,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.ember500, AppColors.punchRed],
                          ),
                          borderRadius: BorderRadius.circular(Sp.rpill),
                        ),
                      ),
                    ),
                    // Thumb
                    Positioned(
                      left: thumbX,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.punchRed, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.punchRed.withValues(alpha: 0.25),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _labels.map((l) {
            return Text(l, style: AppTextStyles.micro(color: AppColors.lavenderGrey));
          }).toList(),
        ),
      ],
    );
  }
}
