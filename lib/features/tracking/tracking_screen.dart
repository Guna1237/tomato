import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/status_chip.dart';
import '../../data/mock/mock_deliveries.dart';
import 'widgets/route_map_animation.dart';
import 'widgets/tracking_bottom_sheet.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          const RouteMapAnimation(),

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Sp.rpill),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          color: Colors.white.withValues(alpha: 0.75),
                          child: const StatusChip(label: 'En route', tone: ChipTone.enroute, showDot: true),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: 40, height: 40,
                          color: Colors.white.withValues(alpha: 0.75),
                          child: const Icon(Icons.phone_outlined, size: 18, color: AppColors.spaceIndigo),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TrackingBottomSheet(delivery: mockActiveDelivery),
          ),
        ],
      ),
    );
  }
}
