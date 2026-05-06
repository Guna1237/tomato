import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../data/mock/mock_user.dart';
import '../../data/mock/mock_deliveries.dart';
import 'widgets/wallet_hero_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/active_delivery_card.dart';
import 'widgets/campus_map_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Morning' : hour < 17 ? 'Afternoon' : 'Evening';
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[now.weekday - 1];
    final timeStr = '${hour % 12 == 0 ? 12 : hour % 12}:${now.minute.toString().padLeft(2, '0')} ${hour < 12 ? 'AM' : 'PM'}';

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$dayName · $timeStr',
                      style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$greeting, ${mockCurrentUser.name.split(' ').first}.',
                      style: AppTextStyles.h1(color: fg1),
                    ),
                  ],
                ),
                _BellButton(bg: bg),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                WalletHeroCard(
                  credits: mockCurrentUser.credits,
                  streakDays: mockCurrentUser.streakDays,
                ),
                const SizedBox(height: 20),

                const SectionHeader(title: 'Quick actions'),
                const SizedBox(height: 12),
                const QuickActionsGrid(),
                const SizedBox(height: 24),

                const SectionHeader(
                  title: 'Active delivery',
                  actionLabel: 'Track',
                ),
                const SizedBox(height: 12),
                ActiveDeliveryCard(delivery: mockActiveDelivery),
                const SizedBox(height: 24),

                SectionHeader(
                  title: 'Around campus',
                  actionLabel: 'Map',
                  onAction: () => context.go('/assistant'),
                ),
                const SizedBox(height: 12),
                const CampusMapCard(),
                const SizedBox(height: 16),

                // AI insight card
                GestureDetector(
                  onTap: () => context.push('/assistant'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.punchRed.withValues(alpha: 0.06),
                          AppColors.ember500.withValues(alpha: 0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(Sp.rxl),
                      border: Border.all(
                        color: AppColors.punchRed.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0A2B2D42), blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                          child: const Icon(Icons.auto_awesome_rounded,
                              color: AppColors.punchRed, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Suggestion',
                                  style: AppTextStyles.micro(color: AppColors.punchRed)),
                              const SizedBox(height: 4),
                              Text(
                                'Your last Amazon order is at the gate. Want someone to bring it before your 8 PM lab?',
                                style: AppTextStyles.bodySm(color: fg1),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _BellButton extends StatelessWidget {
  final Color bg;
  const _BellButton({required this.bg});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x0D2B2D42), blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_outlined,
                size: 20,
                color: isDark ? AppColors.platinum : AppColors.spaceIndigo,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.punchRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: surface, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
