import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../shared/widgets/tomato_logo.dart';
import '../../data/mock/mock_transactions.dart';
import '../../data/mock/mock_user.dart';
import 'widgets/wallet_stats_row.dart';
import 'widgets/transaction_list_item.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

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
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.punchRed, AppColors.ember500],
                      stops: [0.0, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(Sp.rxl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.punchRed.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Glows
                      Positioned(
                        top: -20, right: -20,
                        child: Container(
                          width: 150, height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30, left: 10,
                        child: Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      Padding(
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
                                        'Available credit',
                                        style: AppTextStyles.micro(color: Colors.white.withValues(alpha: 0.75)),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '₹${mockCurrentUser.credits}',
                                        style: AppTextStyles.numericLarge(color: Colors.white),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '+₹40 today · ${mockCurrentUser.streakDays}-day streak 🔥',
                                        style: AppTextStyles.meta(color: Colors.white.withValues(alpha: 0.8)),
                                      ),
                                    ],
                                  ),
                                ),
                                const TomatoMark(size: 56),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _HeroBtn(label: 'Earn faster', onPressed: () {}),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _HeroBtn(label: 'Send', solid: true, onPressed: () {}),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const WalletStatsRow(),
                const SizedBox(height: 24),

                const SectionHeader(title: 'Recent activity'),
                const SizedBox(height: 12),
                TomatoCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: List.generate(mockTransactions.length, (i) {
                      return TransactionListItem(
                        transaction: mockTransactions[i],
                        showDivider: i < mockTransactions.length - 1,
                      );
                    }),
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
  final bool solid;
  final VoidCallback onPressed;
  const _HeroBtn({required this.label, this.solid = false, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: solid ? Colors.white.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: solid ? AppColors.punchRed : Colors.white,
          ),
        ),
      ),
    );
  }
}
