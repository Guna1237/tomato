import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/delivery_provider.dart';
import '../../core/providers/notifications_provider.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/wallet_hero_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/active_delivery_card.dart';
import 'widgets/campus_map_card.dart';
import '../../shared/widgets/tomato_card.dart';
import 'widgets/runner_active_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Morning' : hour < 17 ? 'Afternoon' : 'Evening';
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[now.weekday - 1];
    final timeStr = '${hour % 12 == 0 ? 12 : hour % 12}:${now.minute.toString().padLeft(2, '0')} ${hour < 12 ? 'AM' : 'PM'}';

    final userAsync = ref.watch(currentUserProvider);
    final activeDeliveryAsync = ref.watch(activeDeliveryProvider);
    final openJobsAsync = ref.watch(openDeliveriesProvider);

    final firstName = userAsync.valueOrNull?.displayName.split(' ').first ?? 'there';
    final credits = userAsync.valueOrNull?.tomatoCredits ?? 0;
    final streak = userAsync.valueOrNull?.streakDays ?? 0;
    final isRunnerActive = (userAsync.valueOrNull?.isRunner ?? false) &&
        (userAsync.valueOrNull?.runnerActive ?? false);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),

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
                      '$greeting, $firstName.',
                      style: AppTextStyles.h1(color: fg1),
                    ),
                  ],
                ),
                _BellButton(bg: bg),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                WalletHeroCard(credits: credits, streakDays: streak),
                const SizedBox(height: 20),

                if (isRunnerActive) ...[
                  openJobsAsync.when(
                    data: (jobs) => RunnerActiveCard(
                      openJobCount: jobs.length,
                      onTap: () => context.push('/runner'),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                ],

                const SectionHeader(title: 'Quick actions'),
                const SizedBox(height: 12),
                const QuickActionsGrid(),
                const SizedBox(height: 24),

                // Active delivery — only shown when one exists
                activeDeliveryAsync.when(
                  data: (delivery) {
                    if (delivery == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Active delivery',
                          actionLabel: 'Track',
                          onAction: () =>
                              context.go('/tracking?delivery_id=${delivery.id}'),
                        ),
                        const SizedBox(height: 12),
                        ActiveDeliveryCard(delivery: delivery),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                SectionHeader(
                  title: 'Around campus',
                  actionLabel: 'Map',
                  onAction: () => context.go('/assistant'),
                ),
                const SizedBox(height: 12),
                const CampusMapCard(),
                const SizedBox(height: 16),

                TomatoCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => context.push('/assistant'),
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
                        child: const Icon(Icons.tips_and_updates_outlined,
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
                              'Have a parcel at the gate? Request a pickup and a runner will bring it to your hostel.',
                              style: AppTextStyles.bodySm(color: fg1),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _BellButton extends ConsumerWidget {
  final Color bg;
  const _BellButton({required this.bg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final unreadCount = ref.watch(unreadCountProvider);

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
            if (unreadCount > 0)
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
