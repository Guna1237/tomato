import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/tomato_card.dart';
import '../../../data/mock/mock_admin.dart';

class KpiCard extends StatelessWidget {
  final AdminKpi kpi;
  const KpiCard({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return TomatoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kpi.label.toUpperCase(), style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
          const SizedBox(height: 6),
          Text(kpi.value, style: AppTextStyles.numericMed(color: fg1).copyWith(fontSize: 26)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                kpi.isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: kpi.color,
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  kpi.trend,
                  style: AppTextStyles.micro(color: kpi.color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
