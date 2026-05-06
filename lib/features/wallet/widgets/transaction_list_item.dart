import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock/mock_transactions.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final bool showDivider;
  const TransactionListItem({super.key, required this.transaction, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: transaction.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  transaction.isEarning
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: transaction.iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.title, style: AppTextStyles.bodySmSemibold(color: fg1)),
                    Text(transaction.subtitle, style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.displayAmount,
                    style: AppTextStyles.bodySmSemibold(
                      color: transaction.isEarning ? AppColors.leaf500 : fg1,
                    ),
                  ),
                  Text(
                    transaction.date.split(',').first,
                    style: AppTextStyles.micro(color: AppColors.lavenderGrey),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42),
          ),
      ],
    );
  }
}
