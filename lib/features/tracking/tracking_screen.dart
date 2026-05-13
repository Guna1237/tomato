import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/delivery_provider.dart';
import '../../data/models/delivery.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/tomato_button.dart';
import 'widgets/route_map_animation.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  late String _deliveryId;
  bool _isActionLoading = false;
  Timer? _locationTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deliveryId =
        GoRouterState.of(context).uri.queryParameters['delivery_id'] ?? '';
  }

  void _startLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _pushLocation();
    });
    _pushLocation(); // push immediately on start
  }

  Future<void> _pushLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied ||
            req == LocationPermission.deniedForever) { return; }
      }
      if (permission == LocationPermission.deniedForever) { return; }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      await supabase.from('deliveries').update({
        'runner_lat': pos.latitude,
        'runner_lng': pos.longitude,
        'runner_location_updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _deliveryId);
    } catch (_) {
      // Silently ignore — location is best-effort
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateStatus(DeliveryStatus newStatus) async {
    setState(() => _isActionLoading = true);
    try {
      await DeliveryRepository.updateStatus(
        deliveryId: _deliveryId,
        newStatus: newStatus,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _confirmWithPin(String enteredPin) async {
    setState(() => _isActionLoading = true);
    try {
      final delivery = ref.read(deliveryByIdProvider(_deliveryId)).valueOrNull;
      if (delivery == null) return;
      if (enteredPin != delivery.deliveryPin) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wrong PIN, try again')),
          );
        }
        return;
      }
      await supabase.functions
          .invoke('transfer-credits', body: {'delivery_id': _deliveryId});
      ref.invalidate(deliveryByIdProvider(_deliveryId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery confirmed. Tomatos transferred.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _dialOtherParty(Delivery delivery, bool isRunner) async {
    final otherUserId =
        isRunner ? delivery.requesterId : delivery.runnerId;
    if (otherUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No phone number on file for this user'),
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }
    final row = await supabase
        .from('profiles')
        .select('phone_number')
        .eq('id', otherUserId)
        .maybeSingle();
    final phone = row?['phone_number'] as String?;
    if (phone == null || phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No phone number on file for this user'),
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }
    final digits = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    final uri = Uri(scheme: 'tel', path: digits);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final deliveryAsync = _deliveryId.isEmpty
        ? ref.watch(activeDeliveryProvider)
        : ref.watch(deliveryByIdProvider(_deliveryId));
    final currentUserId = ref.watch(currentUserIdProvider);

    // Start location updates when runner has an active delivery
    deliveryAsync.whenData((delivery) {
      if (delivery == null) return;
      final isRunner = delivery.runnerId == currentUserId;
      final isActive = delivery.status == DeliveryStatus.accepted ||
          delivery.status == DeliveryStatus.pickedUp ||
          delivery.status == DeliveryStatus.enRoute;
      if (isRunner && isActive && _locationTimer == null) {
        _startLocationUpdates();
      }
      if (!isActive) {
        _locationTimer?.cancel();
        _locationTimer = null;
      }
    });

    final delivery = deliveryAsync.valueOrNull;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map with live runner location
          RouteMapAnimation(
            runnerLat: delivery?.runnerLat,
            runnerLng: delivery?.runnerLng,
          ),

          // Top frosted bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: const BackButtonWidget(
                          backgroundColor: Color(0xBBFFFFFF),
                        ),
                      ),
                    ),
                    const Spacer(),
                    deliveryAsync.when(
                      data: (delivery) => ClipRRect(
                        borderRadius: BorderRadius.circular(Sp.rpill),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            color: Colors.white.withValues(alpha: 0.75),
                            child: StatusChip(
                              label: delivery?.status.label ?? 'Tracking',
                              tone: _chipTone(delivery?.status),
                              showDot: true,
                            ),
                          ),
                        ),
                      ),
                      loading: () => ClipRRect(
                        borderRadius: BorderRadius.circular(Sp.rpill),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            color: Colors.white.withValues(alpha: 0.75),
                            child: const StatusChip(
                                label: 'En route',
                                tone: ChipTone.enroute,
                                showDot: true),
                          ),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 10),
                    deliveryAsync.when(
                      data: (delivery) {
                        if (delivery == null) return const SizedBox.shrink();
                        final isRunner = delivery.runnerId == currentUserId;
                        return GestureDetector(
                          onTap: () => _dialOtherParty(delivery, isRunner),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                width: 40,
                                height: 40,
                                color: Colors.white.withValues(alpha: 0.75),
                                child: const Icon(Icons.phone_outlined,
                                    size: 18, color: AppColors.spaceIndigo),
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(width: 40, height: 40),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom sheet with live delivery data
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: deliveryAsync.when(
              data: (delivery) {
                if (delivery == null) return const SizedBox.shrink();
                final isRunner = delivery.runnerId == currentUserId;
                return _TrackingBottomSheet(
                  delivery: delivery,
                  isRunner: isRunner,
                  isActionLoading: _isActionLoading,
                  onUpdateStatus: _updateStatus,
                  onConfirmWithPin: _confirmWithPin,
                );
              },
              loading: () => _LoadingBottomSheet(),
              error: (e, _) => _ErrorBottomSheet(error: e.toString()),
            ),
          ),
        ],
      ),
    );
  }

  ChipTone _chipTone(DeliveryStatus? status) {
    switch (status) {
      case DeliveryStatus.matching:
        return ChipTone.matching;
      case DeliveryStatus.enRoute:
        return ChipTone.enroute;
      case DeliveryStatus.delivered:
        return ChipTone.delivered;
      case DeliveryStatus.cancelled:
        return ChipTone.warn;
      default:
        return ChipTone.neutral;
    }
  }
}

// ---------------------------------------------------------------------------
// Main bottom sheet — wired to real delivery data
// ---------------------------------------------------------------------------

class _TrackingBottomSheet extends StatefulWidget {
  final Delivery delivery;
  final bool isRunner;
  final bool isActionLoading;
  final Future<void> Function(DeliveryStatus) onUpdateStatus;
  final Future<void> Function(String) onConfirmWithPin;

  const _TrackingBottomSheet({
    required this.delivery,
    required this.isRunner,
    required this.isActionLoading,
    required this.onUpdateStatus,
    required this.onConfirmWithPin,
  });

  @override
  State<_TrackingBottomSheet> createState() => _TrackingBottomSheetState();
}

class _TrackingBottomSheetState extends State<_TrackingBottomSheet> {
  final TextEditingController _pinController = TextEditingController();
  bool _isCalling = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _callOtherParty() async {
    if (_isCalling) return;
    setState(() => _isCalling = true);
    try {
      final otherUserId = widget.isRunner
          ? widget.delivery.requesterId
          : widget.delivery.runnerId;
      if (otherUserId == null) {
        _showNoPhone();
        return;
      }
      final row = await supabase
          .from('profiles')
          .select('phone_number')
          .eq('id', otherUserId)
          .maybeSingle();
      final phone = row?['phone_number'] as String?;
      if (phone == null || phone.isEmpty) {
        _showNoPhone();
        return;
      }
      final digits = phone.replaceAll(RegExp(r'[\s\-()]'), '');
      final uri = Uri(scheme: 'tel', path: digits);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showNoPhone();
      }
    } finally {
      if (mounted) setState(() => _isCalling = false);
    }
  }

  void _showNoPhone() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('No phone number on file for this user'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    Widget? actionButton = _buildActionButton(context, isDark);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Sp.r2xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
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
          const SizedBox(height: 18),

          // Route summary
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.delivery.pickupLocation} → ${widget.delivery.dropoffLocation}',
                      style: AppTextStyles.h4(color: fg1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.delivery.status.label,
                      style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.punchRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'T\$${widget.delivery.creditCost}',
                  style: AppTextStyles.metaSemibold(color: AppColors.punchRed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Divider(height: 1),
          const SizedBox(height: 20),

          // Status stepper driven by real delivery status
          _LiveDeliveryStepper(status: widget.delivery.status),
          const SizedBox(height: 20),

          // PIN display for requester — stays visible until transfer completes
          if (!widget.isRunner &&
              (widget.delivery.status == DeliveryStatus.accepted ||
                  widget.delivery.status == DeliveryStatus.pickedUp ||
                  widget.delivery.status == DeliveryStatus.enRoute ||
                  widget.delivery.status == DeliveryStatus.delivered) &&
              widget.delivery.deliveryPin != null) ...[
            _PinDisplay(pin: widget.delivery.deliveryPin!),
            const SizedBox(height: 20),
          ],

          // Utility row
          Row(
            children: [
              Expanded(
                child: TomatoButton(
                  label: 'Chat',
                  variant: TomatoButtonVariant.secondary,
                  leading: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  isFullWidth: true,
                  onTap: () => context.push(
                      '/messaging?delivery_id=${widget.delivery.id}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TomatoButton(
                  label: widget.isRunner ? 'Call requester' : 'Call runner',
                  variant: TomatoButtonVariant.soft,
                  leading: const Icon(Icons.call_outlined, size: 16),
                  isFullWidth: true,
                  isLoading: _isCalling,
                  onTap: _isCalling ? null : _callOtherParty,
                ),
              ),
            ],
          ),

          // Action button
          if (actionButton != null) ...[
            const SizedBox(height: 12),
            actionButton,
          ],
        ],
      ),
    );
  }

  Widget? _buildActionButton(BuildContext context, bool isDark) {
    if (widget.isRunner) {
      switch (widget.delivery.status) {
        case DeliveryStatus.accepted:
          return TomatoButton(
            label: 'Mark Picked Up',
            isFullWidth: true,
            size: TomatoButtonSize.lg,
            isLoading: widget.isActionLoading,
            onTap: widget.isActionLoading
                ? null
                : () => widget.onUpdateStatus(DeliveryStatus.pickedUp),
          );
        case DeliveryStatus.pickedUp:
          return TomatoButton(
            label: 'Mark En Route',
            isFullWidth: true,
            size: TomatoButtonSize.lg,
            isLoading: widget.isActionLoading,
            onTap: widget.isActionLoading
                ? null
                : () => widget.onUpdateStatus(DeliveryStatus.enRoute),
          );
        case DeliveryStatus.enRoute:
          return TomatoButton(
            label: 'Mark Delivered',
            isFullWidth: true,
            size: TomatoButtonSize.lg,
            isLoading: widget.isActionLoading,
            onTap: widget.isActionLoading
                ? null
                : () => widget.onUpdateStatus(DeliveryStatus.delivered),
          );
        case DeliveryStatus.delivered:
          // Runner enters PIN to confirm
          return _PinEntry(
            controller: _pinController,
            isLoading: widget.isActionLoading,
            onConfirm: () => widget.onConfirmWithPin(_pinController.text.trim()),
            isDark: isDark,
          );
        default:
          return null;
      }
    } else {
      // Requester: no button needed — PIN is displayed above
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// PIN display widget (requester sees this)
// ---------------------------------------------------------------------------

class _PinDisplay extends StatelessWidget {
  final String pin;
  const _PinDisplay({required this.pin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Your delivery PIN',
          style: AppTextStyles.metaSemibold(color: AppColors.lavenderGrey),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pin.length, (i) {
            return Padding(
              padding: EdgeInsets.only(right: i < pin.length - 1 ? 8 : 0),
              child: Container(
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.punchRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  pin[i],
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.punchRed,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Share this with the runner when they arrive.',
          style: AppTextStyles.meta(color: AppColors.lavenderGrey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PIN entry widget (runner enters PIN to confirm delivery)
// ---------------------------------------------------------------------------

class _PinEntry extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onConfirm;
  final bool isDark;

  const _PinEntry({
    required this.controller,
    required this.isLoading,
    required this.onConfirm,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: fg1,
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            hintText: '----',
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.lavenderGrey.withValues(alpha: 0.4),
              letterSpacing: 12,
            ),
            counterText: '',
            filled: true,
            fillColor: isDark
                ? AppColors.darkElevated
                : AppColors.punchRed.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
        ),
        const SizedBox(height: 10),
        TomatoButton(
          label: 'Confirm delivery',
          isFullWidth: true,
          size: TomatoButtonSize.lg,
          isLoading: isLoading,
          onTap: isLoading ? null : onConfirm,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Live stepper driven by real DeliveryStatus
// ---------------------------------------------------------------------------

class _LiveDeliveryStepper extends StatelessWidget {
  final DeliveryStatus status;
  const _LiveDeliveryStepper({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Steps in order: accepted → pickedUp → enRoute → delivered
    final ordered = [
      (DeliveryStatus.accepted, 'Runner assigned'),
      (DeliveryStatus.pickedUp, 'Picked up'),
      (DeliveryStatus.enRoute, 'En route'),
      (DeliveryStatus.delivered, 'Delivered'),
    ];

    final currentIndex = ordered.indexWhere((s) => s.$1 == status);

    return Column(
      children: List.generate(ordered.length, (i) {
        final (_, label) = ordered[i];
        final done = currentIndex > i;
        final current = currentIndex == i;
        final isLast = i == ordered.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: done
                        ? AppColors.leaf500
                        : current
                            ? AppColors.punchRed
                            : (isDark
                                ? AppColors.darkElevated
                                : const Color(0xFFE2E6EA)),
                    shape: BoxShape.circle,
                    boxShadow: current
                        ? [
                            BoxShadow(
                              color: AppColors.punchRed.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: done && !current
                      ? const Icon(Icons.check, color: Colors.white, size: 9)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 1.5,
                    height: 32,
                    color: done
                        ? AppColors.leaf500.withValues(alpha: 0.4)
                        : (isDark
                            ? const Color(0x18EDF2F4)
                            : const Color(0x0F2B2D42)),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Text(
                label,
                style: current
                    ? AppTextStyles.bodySmSemibold(color: AppColors.punchRed)
                    : done
                        ? AppTextStyles.bodySm(color: AppColors.lavenderGrey)
                        : AppTextStyles.bodySm(
                            color: AppColors.lavenderGrey
                                .withValues(alpha: 0.5)),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading / error bottom sheet stubs
// ---------------------------------------------------------------------------

class _LoadingBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Sp.r2xl)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.punchRed,
        ),
      ),
    );
  }
}

class _ErrorBottomSheet extends StatelessWidget {
  final String error;
  const _ErrorBottomSheet({required this.error});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Sp.r2xl)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Text(
        'Could not load delivery: $error',
        style: AppTextStyles.meta(color: AppColors.lavenderGrey),
      ),
    );
  }
}
