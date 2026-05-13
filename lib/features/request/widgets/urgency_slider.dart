import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class UrgencySlider extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final double initialValue;

  const UrgencySlider({
    super.key,
    required this.onChanged,
    this.initialValue = 0.5,
  });

  @override
  State<UrgencySlider> createState() => _UrgencySliderState();
}

class _UrgencySliderState extends State<UrgencySlider> {
  late double _value;

  // Left = 15 min (most urgent, highest cost), Right = Tomorrow (lowest cost)
  static const _labels = ['15 min', 'Today', 'Tomorrow'];

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  String get _activeLabel {
    if (_value < 0.33) return '15 min';
    if (_value < 0.67) return 'Today';
    return 'Tomorrow';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final trackBg = isDark ? const Color(0x18EDF2F4) : const Color(0x0F2B2D42);

    const thumbSize = 28.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Urgency', style: AppTextStyles.h4(color: fg1)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.punchRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Sp.rpill),
              ),
              child: Text(
                _activeLabel,
                style: AppTextStyles.micro(color: AppColors.punchRed),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final trackW = constraints.maxWidth;
            // Usable range for the thumb center: [thumbSize/2 .. trackW - thumbSize/2]
            final usable = trackW - thumbSize;
            final thumbLeft = _value * usable;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (d) {
                final newVal = ((d.localPosition.dx - thumbSize / 2) / usable)
                    .clamp(0.0, 1.0);
                setState(() => _value = newVal);
                widget.onChanged(_value);
              },
              onHorizontalDragUpdate: (d) {
                final newVal = ((d.localPosition.dx - thumbSize / 2) / usable)
                    .clamp(0.0, 1.0);
                setState(() => _value = newVal);
                widget.onChanged(_value);
              },
              onTapDown: (d) {
                final newVal = ((d.localPosition.dx - thumbSize / 2) / usable)
                    .clamp(0.0, 1.0);
                setState(() => _value = newVal);
                widget.onChanged(_value);
              },
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Track background
                    Positioned(
                      left: thumbSize / 2,
                      right: thumbSize / 2,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: trackBg,
                          borderRadius: BorderRadius.circular(Sp.rpill),
                        ),
                      ),
                    ),
                    // Filled track (from left to thumb center)
                    Positioned(
                      left: thumbSize / 2,
                      width: thumbLeft,
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
                      left: thumbLeft,
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.punchRed, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.punchRed.withValues(alpha: 0.2),
                              blurRadius: 8,
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
            final isActive = l == _activeLabel;
            return Text(
              l,
              style: AppTextStyles.micro(
                color: isActive ? AppColors.punchRed : AppColors.lavenderGrey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
