import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/delivery_provider.dart';
import '../../data/models/delivery.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/tomato_button.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../shared/widgets/section_header.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _notesController = TextEditingController();

  // Size: 0=S, 1=M, 2=L
  int _selectedSizeIndex = 1;
  String get _selectedSize => ['S', 'M', 'L'][_selectedSizeIndex];

  // Urgency slider 0.0–1.0 maps to multiplier 1.0–1.5
  double _urgencyValue = 0.5;
  double get _urgencyMultiplier => 1.0 + _urgencyValue * 0.5;

  bool _isLoading = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider).value!;
      final delivery = await DeliveryRepository.createDelivery(
        requesterId: user.id,
        pickupLocation: _pickupController.text.trim().isEmpty
            ? 'Main Gate - Parcel Center'
            : _pickupController.text.trim(),
        dropoffLocation: _dropoffController.text.trim().isEmpty
            ? 'H4 North Wing'
            : _dropoffController.text.trim(),
        itemSize: _selectedSize,
        urgency: _urgencyMultiplier,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      // Broadcast to runners
      await supabase.functions.invoke('match-runner', body: {
        'delivery_id': delivery.id,
        'requester_id': user.id,
      });
      if (mounted) context.go('/matching?delivery_id=${delivery.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final userAsync = ref.watch(currentUserProvider);
    final creditCost = Delivery.computeCost(_selectedSize, _urgencyMultiplier);
    final userCredits = userAsync.valueOrNull?.tomatoCredits ?? 0;
    final canAfford = userCredits >= creditCost;
    final shortfall = creditCost - userCredits;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Column(
            children: [
              AppStatusBar(dark: isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const BackButtonWidget(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Request a pickup', style: AppTextStyles.h3(color: fg1)),
                          Text('Step 1 of 3',
                              style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Step progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                        height: 3,
                        decoration: BoxDecoration(
                          color: i <= 1
                              ? AppColors.punchRed
                              : AppColors.lavenderGrey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Sp.rpill),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                  children: [
                    const SectionHeader(title: 'Route'),
                    const SizedBox(height: 12),
                    _LocationCard(
                      pickupController: _pickupController,
                      dropoffController: _dropoffController,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    const SectionHeader(title: 'Parcel size'),
                    const SizedBox(height: 12),
                    _SizePickerInline(
                      selected: _selectedSizeIndex,
                      onChanged: (i) => setState(() => _selectedSizeIndex = i),
                    ),
                    const SizedBox(height: 24),

                    _UrgencySliderInline(
                      value: _urgencyValue,
                      onChanged: (v) => setState(() => _urgencyValue = v),
                    ),
                    const SizedBox(height: 24),

                    // Notes card
                    TomatoCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notes (optional)', style: AppTextStyles.h4(color: fg1)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            style: AppTextStyles.body(color: fg1),
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'e.g. "I\'m in class till 4. Knock on H4-205."',
                              hintStyle: AppTextStyles.body(
                                  color: AppColors.lavenderGrey.withValues(alpha: 0.6)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _ChipButton(
                                label: '📷  Photo',
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Photo attachments coming soon'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _ChipButton(
                                label: '🎙  Voice note',
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Voice notes coming soon'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Cost estimate card — now shows live computed cost
                    TomatoCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Estimated cost',
                                  style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                              const SizedBox(height: 4),
                              Text('T$creditCost',
                                  style: AppTextStyles.h3(color: fg1)),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Your balance',
                                  style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                              const SizedBox(height: 4),
                              Text(
                                'T$userCredits',
                                style: AppTextStyles.h3(
                                  color: canAfford
                                      ? AppColors.punchRed
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Sticky bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bg.withValues(alpha: 0),
                    bg,
                  ],
                ),
              ),
              child: canAfford
                  ? TomatoButton(
                      label: 'Find a helper · T$creditCost',
                      isFullWidth: true,
                      size: TomatoButtonSize.lg,
                      isLoading: _isLoading,
                      onTap: _isLoading ? null : _submit,
                    )
                  : TomatoButton(
                      label: 'Need T$shortfall more',
                      isFullWidth: true,
                      size: TomatoButtonSize.lg,
                      variant: TomatoButtonVariant.secondary,
                      onTap: null,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Location card (lifted state — reads from controllers)
// ---------------------------------------------------------------------------

class _LocationCard extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final bool isDark;

  const _LocationCard({
    required this.pickupController,
    required this.dropoffController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return TomatoCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Connector line
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.punchRed,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 1.5,
                height: 36,
                color: AppColors.lavenderGrey.withValues(alpha: 0.3),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lavenderGrey, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PICKUP FROM',
                    style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                const SizedBox(height: 4),
                TextField(
                  controller: pickupController,
                  style: AppTextStyles.bodySmSemibold(color: fg1),
                  decoration: InputDecoration(
                    hintText: 'Main Gate - Parcel Center',
                    hintStyle: AppTextStyles.bodySmSemibold(
                        color: AppColors.lavenderGrey.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Divider(
                    height: 20,
                    color: AppColors.lavenderGrey.withValues(alpha: 0.15)),
                Text('DELIVER TO',
                    style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                const SizedBox(height: 4),
                TextField(
                  controller: dropoffController,
                  style: AppTextStyles.bodySmSemibold(color: fg1),
                  decoration: InputDecoration(
                    hintText: 'H4 North Wing',
                    hintStyle: AppTextStyles.bodySmSemibold(
                        color: AppColors.lavenderGrey.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              final pickup = pickupController.text;
              pickupController.text = dropoffController.text;
              dropoffController.text = pickup;
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.punchRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.swap_vert_rounded,
                  color: AppColors.punchRed, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Size picker (inline, identical visual to SizePicker widget)
// ---------------------------------------------------------------------------

class _SizePickerInline extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _SizePickerInline({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final sizes = [
      (Icons.inventory_2_outlined, 'Small', 'Fits in a bag'),
      (Icons.shopping_bag_outlined, 'Medium', 'Shoebox size'),
      (Icons.luggage_outlined, 'Large', 'Carry-on bag'),
    ];

    return Row(
      children: List.generate(sizes.length, (i) {
        final (icon, label, sub) = sizes[i];
        final isSelected = i == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: TomatoCard(
                isSelected: isSelected,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.punchRed.withValues(alpha: 0.12)
                            : (isDark
                                ? AppColors.darkElevated
                                : AppColors.bgSunken),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? AppColors.punchRed
                            : AppColors.lavenderGrey,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(label, style: AppTextStyles.bodySmSemibold(color: fg1)),
                    Text(sub,
                        style:
                            AppTextStyles.micro(color: AppColors.lavenderGrey)),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Urgency slider (inline, identical visual to UrgencySlider widget)
// ---------------------------------------------------------------------------

class _UrgencySliderInline extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _UrgencySliderInline(
      {required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final trackBg =
        isDark ? const Color(0x18EDF2F4) : const Color(0x0F2B2D42);

    final labels = ['15 min', 'Today', 'Tomorrow'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Urgency', style: AppTextStyles.h4(color: fg1)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final trackW = constraints.maxWidth;
            final thumbX = value * (trackW - 28);

            return GestureDetector(
              onHorizontalDragUpdate: (d) {
                final next =
                    ((value * trackW + d.delta.dx) / trackW).clamp(0.0, 1.0);
                onChanged(next);
              },
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Track background
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: trackBg,
                        borderRadius: BorderRadius.circular(Sp.rpill),
                      ),
                    ),
                    // Filled track
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.ember500, AppColors.punchRed],
                          ),
                          borderRadius: BorderRadius.circular(Sp.rpill),
                        ),
                      ),
                    ),
                    // Thumb
                    Positioned(
                      left: thumbX,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.punchRed, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.punchRed.withValues(alpha: 0.25),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map((l) => Text(l,
                  style: AppTextStyles.micro(color: AppColors.lavenderGrey)))
              .toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chip button (unchanged from original)
// ---------------------------------------------------------------------------

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ChipButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkElevated : AppColors.bgSunken,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
      ),
    );
  }
}
