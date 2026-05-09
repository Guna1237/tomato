import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/credit_transaction.dart';

class TransactionListItem extends StatelessWidget {
  final CreditTransaction transaction;
  final bool showDivider;
  const TransactionListItem({super.key, required this.transaction, this.showDivider = true});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    if (date == today) {
      final h = dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final period = h < 12 ? 'AM' : 'PM';
      final hour = h % 12 == 0 ? 12 : h % 12;
      return 'Today, $hour:$m $period';
    }
    if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final isIncoming = transaction.isIncoming;
    final amountColor = isIncoming ? AppColors.leaf500 : AppColors.punchRed;
    final iconColor = amountColor;
    final amountText = '${isIncoming ? '+' : '-'}T${transaction.amount}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isIncoming
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.displayLabel, style: AppTextStyles.bodySmSemibold(color: fg1)),
                    Text(_formatDate(transaction.createdAt), style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: AppTextStyles.bodySmSemibold(color: amountColor),
                  ),
                  Text(
                    _formatDate(transaction.createdAt).split(',').first,
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
