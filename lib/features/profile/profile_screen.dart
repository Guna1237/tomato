import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../data/mock/mock_user.dart';
import 'widgets/reliability_ring.dart';
import 'widgets/badge_grid.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    const user = mockCurrentUser;

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
                Text('Profile', style: AppTextStyles.h1(color: fg1)),
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42),
                      ),
                    ),
                    child: Icon(Icons.settings_outlined, color: fg1, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                // Profile header card
                TomatoCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 72, height: 72,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFFC4B0), Color(0xFFFF8A97)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    user.initials,
                                    style: AppTextStyles.h2(color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 22, height: 22,
                                  decoration: const BoxDecoration(
                                    color: AppColors.leaf500,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white, size: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(user.name, style: AppTextStyles.h3(color: fg1)),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified_rounded, color: AppColors.punchRed, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(user.rollNumber, style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                                Text(user.hostel, style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42)),
                      const SizedBox(height: 16),

                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Stat(value: '${user.totalDeliveries}', label: 'Deliveries'),
                          _Stat(value: '${user.totalRequests}', label: 'Requests'),
                          _Stat(value: '${user.streakDays}d', label: 'Streak'),
                          _Stat(value: '₹${user.credits}', label: 'Credits'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const SectionHeader(title: 'Reliability'),
                const SizedBox(height: 16),
                Center(child: ReliabilityRing(reliability: user.reliability)),
                const SizedBox(height: 24),

                const SectionHeader(title: 'Badges'),
                const SizedBox(height: 12),
                const BadgeGrid(),
                const SizedBox(height: 24),

                const SectionHeader(title: 'Recent reviews'),
                const SizedBox(height: 12),
                ...[
                  ('Aryan Singh', 'Fast and reliable! Got my parcel in under 8 min.', 5),
                  ('Priya Mehta', 'Super helpful. Would definitely request again.', 5),
                ].map((r) {
                  final (name, quote, stars) = r;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TomatoCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(name, style: AppTextStyles.bodySmSemibold(color: fg1)),
                              const Spacer(),
                              Row(
                                children: List.generate(stars, (_) {
                                  return const Icon(Icons.star_rounded, color: AppColors.ember500, size: 14);
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(quote, style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    return Column(
      children: [
        Text(value, style: AppTextStyles.h3(color: fg1)),
        Text(label, style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
      ],
    );
  }
}
