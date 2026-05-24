import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/transactions_provider.dart';
import '../../../data/models/credit_transaction.dart';
import '../../../shared/widgets/tomato_card.dart';

class WalletStatsRow extends ConsumerWidget {
  const WalletStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);

    final (earned, spent, helped) = txAsync.maybeWhen(
      data: (txs) {
        int e = 0;
        int s = 0;
        int h = 0;
        for (final t in txs) {
          if (t.type == TransactionType.spend) {
            s += t.amount;
          } else {
            e += t.amount;
            if (t.type == TransactionType.earn) h++;
          }
        }
        return (e, s, h);
      },
      orElse: () => (0, 0, 0),
    );

    return Row(
      children: [
        _StatCard(label: 'Earned', value: '🍅$earned', color: AppColors.leaf500),
        const SizedBox(width: 10),
        _StatCard(label: 'Spent', value: '🍅$spent', color: AppColors.punchRed),
        const SizedBox(width: 10),
        _StatCard(label: 'Helped', value: '$helped', color: AppColors.ember500),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Expanded(
      child: TomatoCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.trending_up_rounded, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.h3(color: fg1)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
          ],
        ),
      ),
    );
  }
}
