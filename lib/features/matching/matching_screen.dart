import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/providers/delivery_provider.dart';
import '../../data/models/delivery.dart';
import '../../data/models/runner_interest.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/profile_avatar.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/tomato_button.dart';
import 'widgets/match_graph_animation.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  late String _deliveryId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deliveryId =
        GoRouterState.of(context).uri.queryParameters['delivery_id'] ?? '';
  }

  Future<void> _selectRunner(RunnerInterest interest) async {
    await DeliveryRepository.selectRunner(
      deliveryId: _deliveryId,
      runnerId: interest.runnerId,
      interestId: interest.id,
    );
    if (mounted) context.go('/tracking?delivery_id=$_deliveryId');
  }

  Future<void> _cancelDelivery() async {
    await supabase
        .from('deliveries')
        .update({'status': 'cancelled'}).eq('id', _deliveryId);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final interestsAsync = ref.watch(runnerInterestsProvider(_deliveryId));
    final deliveryAsync = ref.watch(deliveryByIdProvider(_deliveryId));

    // Determine 5-minute timeout: delivery created > 5 min ago with no interests
    bool isTimedOut = false;
    interestsAsync.whenData((interests) {
      deliveryAsync.whenData((delivery) {
        if (delivery != null &&
            interests.isEmpty &&
            DateTime.now().difference(delivery.createdAt).inMinutes >= 5) {
          isTimedOut = true;
        }
      });
    });

    ref.listen(deliveryByIdProvider(_deliveryId), (prev, next) {
      final delivery = next.valueOrNull;
      if (delivery != null && delivery.status == DeliveryStatus.accepted) {
        context.go('/tracking?delivery_id=${delivery.id}');
      }
    });

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const BackButtonWidget(),
                  const SizedBox(width: 14),
                  interestsAsync.when(
                    data: (interests) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Finding you a helper',
                            style: AppTextStyles.h3(color: fg1)),
                        Text(
                          interests.isEmpty
                              ? 'Looking for runners nearby'
                              : '${interests.length} runner${interests.length == 1 ? '' : 's'} ready',
                          style:
                              AppTextStyles.meta(color: AppColors.lavenderGrey),
                        ),
                      ],
                    ),
                    loading: () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Finding you a helper',
                            style: AppTextStyles.h3(color: fg1)),
                        Text('Looking for runners nearby',
                            style: AppTextStyles.meta(
                                color: AppColors.lavenderGrey)),
                      ],
                    ),
                    error: (_, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Finding you a helper',
                            style: AppTextStyles.h3(color: fg1)),
                        Text('Searching...',
                            style: AppTextStyles.meta(
                                color: AppColors.lavenderGrey)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const StatusChip(
                      label: 'Matching', tone: ChipTone.matching),
                ],
              ),
            ),
          ),

          // Graph animation as decorative background
          const Expanded(child: MatchGraphAnimation()),

          // Live runner cards section
          interestsAsync.when(
            data: (interests) {
              if (isTimedOut) {
                return _TimeoutState(onCancel: _cancelDelivery);
              }
              if (interests.isEmpty) {
                return _WaitingState();
              }
              return _RunnerList(
                interests: interests,
                onSelect: _selectRunner,
              );
            },
            loading: () => _WaitingState(),
            error: (e, _) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Text(
                'Error: $e',
                style: AppTextStyles.meta(color: AppColors.lavenderGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Waiting state (no runners yet, no timeout)
// ---------------------------------------------------------------------------

class _WaitingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Sp.r2xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lavenderGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Sp.rpill),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.punchRed,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Waiting for runners...',
                style: AppTextStyles.h4(color: fg1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Runners in the area are being notified.',
            style: AppTextStyles.meta(color: AppColors.lavenderGrey),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Runner list (interests available)
// ---------------------------------------------------------------------------

class _RunnerList extends StatelessWidget {
  final List<RunnerInterest> interests;
  final Future<void> Function(RunnerInterest) onSelect;

  const _RunnerList({required this.interests, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Sp.r2xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lavenderGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(Sp.rpill),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${interests.length} runner${interests.length == 1 ? '' : 's'} ready',
                  style: AppTextStyles.h4(color: fg1),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.punchRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Sp.rpill),
                  ),
                  child: Text(
                    'Pick one',
                    style: AppTextStyles.micro(color: AppColors.punchRed),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: interests.length,
              itemBuilder: (_, i) => _RunnerCard(
                interest: interests[i],
                onSelect: () => onSelect(interests[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeout state (no runners after 5 min)
// ---------------------------------------------------------------------------

class _TimeoutState extends StatelessWidget {
  final VoidCallback onCancel;
  const _TimeoutState({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Sp.r2xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lavenderGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Sp.rpill),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No runners available',
            style: AppTextStyles.h4(color: fg1),
          ),
          const SizedBox(height: 8),
          Text(
            'No one picked up your request in time.',
            style: AppTextStyles.meta(color: AppColors.lavenderGrey),
          ),
          const SizedBox(height: 20),
          TomatoButton(
            label: 'Cancel & refund',
            isFullWidth: true,
            variant: TomatoButtonVariant.soft,
            onTap: onCancel,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Runner card
// ---------------------------------------------------------------------------

class _RunnerCard extends StatelessWidget {
  final RunnerInterest interest;
  final VoidCallback onSelect;
  const _RunnerCard({required this.interest, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final runner = interest.runnerProfile;
    final bg = isDark ? const Color(0xFF1A1B2C) : Colors.white;
    final fg = isDark ? const Color(0xFFEDF2F4) : const Color(0xFF2B2D42);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0x12EDF2F4)
              : const Color(0x0A2B2D42),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          ProfileAvatar(
            photoPath: runner?.photoUrl,
            displayName: runner?.displayName ?? '?',
            radius: 24,
            backgroundColor: const Color(0xFFEF233C).withValues(alpha: 0.15),
            initialsStyle: const TextStyle(
              color: Color(0xFFEF233C),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  runner?.displayName ?? 'Runner',
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: Color(0xFFFF6A55)),
                    const SizedBox(width: 3),
                    Text(
                      '${((runner?.reliability ?? 1.0) * 100).toInt()}% · ${runner?.streakDays ?? 0}d streak',
                      style: TextStyle(
                        color: fg.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Select button
          GestureDetector(
            onTap: onSelect,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF233C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Select',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
