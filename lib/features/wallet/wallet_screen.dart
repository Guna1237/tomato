import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/transactions_provider.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../shared/widgets/tomato_logo.dart';
import 'widgets/wallet_stats_row.dart';
import 'widgets/transaction_list_item.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final userAsync = ref.watch(currentUserProvider);
    final credits = userAsync.value?.tomatoCredits ?? 0;
    final streak = userAsync.value?.streakDays ?? 0;
    final txAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Wallet', style: AppTextStyles.h1(color: fg1)),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42),
                    ),
                  ),
                  child: Icon(Icons.qr_code_rounded, color: fg1, size: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                // Hero card
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkElevated : AppColors.punchRed,
                    borderRadius: BorderRadius.circular(Sp.rxl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.punchRed.withValues(alpha: isDark ? 0.12 : 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tomato balance',
                                    style: AppTextStyles.micro(color: Colors.white.withValues(alpha: 0.75)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'T$credits',
                                    style: AppTextStyles.numericLarge(color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$streak-day streak',
                                    style: AppTextStyles.meta(color: Colors.white.withValues(alpha: 0.8)),
                                  ),
                                ],
                              ),
                            ),
                            const TomatoMark(size: 56),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _HeroBtn(
                          label: 'Earn faster',
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Complete deliveries to earn tomatos'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const WalletStatsRow(),
                const SizedBox(height: 24),

                const SectionHeader(title: 'Recent activity'),
                const SizedBox(height: 12),
                TomatoCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: txAsync.when(
                    data: (transactions) => transactions.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No transactions yet'),
                          )
                        : Column(
                            children: List.generate(
                              transactions.length,
                              (i) => TransactionListItem(
                                transaction: transactions[i],
                                showDivider: i < transactions.length - 1,
                              ),
                            ),
                          ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: $e'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _HeroBtn({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
