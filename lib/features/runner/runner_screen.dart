import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/delivery_provider.dart';
import '../../data/models/delivery.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../shared/widgets/tomato_button.dart';
import '../../shared/widgets/tomato_logo.dart';

class RunnerScreen extends ConsumerWidget {
  const RunnerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deliveriesAsync = ref.watch(openDeliveriesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sp.s4,
                vertical: Sp.s2,
              ),
              child: Row(
                children: [
                  const BackButtonWidget(),
                  const SizedBox(width: Sp.s2),
                  Text(
                    'Open jobs',
                    style: AppTextStyles.h2(
                      color: isDark
                          ? AppColors.platinum
                          : AppColors.spaceIndigo,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: deliveriesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Center(
                  child: Text(
                    err.toString(),
                    style: AppTextStyles.meta(
                      color: isDark
                          ? AppColors.platinum
                          : AppColors.spaceIndigo,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (deliveries) {
                  if (deliveries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const TomatoMark(size: 64),
                          const SizedBox(height: Sp.s4),
                          Text(
                            'No open jobs right now',
                            style: AppTextStyles.meta(
                              color: isDark
                                  ? AppColors.platinum
                                  : AppColors.spaceIndigo,
                            ),
                          ),
                          const SizedBox(height: Sp.s1),
                          Text(
                            'Check back soon',
                            style: AppTextStyles.micro(
                              color: AppColors.lavenderGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(Sp.s4),
                    itemCount: deliveries.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Sp.s2),
                    itemBuilder: (context, index) {
                      return RunnerJobCard(delivery: deliveries[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RunnerJobCard extends StatefulWidget {
  final Delivery delivery;

  const RunnerJobCard({super.key, required this.delivery});

  @override
  State<RunnerJobCard> createState() => _RunnerJobCardState();
}

class _RunnerJobCardState extends State<RunnerJobCard> {
  bool _isLoading = false;

  Future<void> _acceptJob() async {
    setState(() => _isLoading = true);
    try {
      await DeliveryRepository.acceptDelivery(widget.delivery.id);
      if (mounted) {
        context.push('/tracking?delivery_id=${widget.delivery.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job already taken - try another one'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final delivery = widget.delivery;

    return TomatoCard(
      padding: const EdgeInsets.all(Sp.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  delivery.pickupLocation,
                  style: AppTextStyles.body(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Sp.s1),
                child: Icon(Icons.arrow_forward_rounded, size: 14),
              ),
              Expanded(
                child: Text(
                  delivery.dropoffLocation,
                  style: AppTextStyles.body(),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sp.s2,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.punchRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Sp.rpill),
                ),
                child: Text(
                  delivery.itemSize,
                  style: AppTextStyles.micro(color: AppColors.punchRed),
                ),
              ),
              const SizedBox(width: Sp.s2),
              Text(
                'T${delivery.creditCost} tomatos',
                style: AppTextStyles.body(color: AppColors.leaf500),
              ),
              const Spacer(),
              TomatoButton(
                label: 'Accept',
                size: TomatoButtonSize.sm,
                variant: TomatoButtonVariant.primary,
                onTap: _isLoading ? null : _acceptJob,
                isLoading: _isLoading,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
