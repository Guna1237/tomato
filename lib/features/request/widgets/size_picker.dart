import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/tomato_card.dart';

class SizePicker extends StatefulWidget {
  const SizePicker({super.key});

  @override
  State<SizePicker> createState() => _SizePickerState();
}

class _SizePickerState extends State<SizePicker> {
  int _selected = 1;

  final _sizes = [
    (Icons.inventory_2_outlined, 'Small', 'Fits in a bag'),
    (Icons.shopping_bag_outlined, 'Medium', 'Shoebox size'),
    (Icons.luggage_outlined, 'Large', 'Carry-on bag'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Row(
      children: List.generate(_sizes.length, (i) {
        final (icon, label, sub) = _sizes[i];
        final selected = i == _selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: TomatoCard(
                isSelected: selected,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.punchRed.withValues(alpha: 0.12)
                            : (isDark ? AppColors.darkElevated : AppColors.bgSunken),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: selected ? AppColors.punchRed : AppColors.lavenderGrey,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(label, style: AppTextStyles.bodySmSemibold(color: fg1)),
                    Text(sub, style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
