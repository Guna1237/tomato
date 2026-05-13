import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';

// Mahindra University, Bahadurpally, Hyderabad
const _campusCenter = LatLng(17.5684696, 78.4362807);

class RouteMapAnimation extends StatelessWidget {
  final double? runnerLat;
  final double? runnerLng;

  const RouteMapAnimation({super.key, this.runnerLat, this.runnerLng});

  @override
  Widget build(BuildContext context) {
    final hasRunnerLocation = runnerLat != null && runnerLng != null;
    final runnerPoint = hasRunnerLocation
        ? LatLng(runnerLat!, runnerLng!)
        : null;

    // If we have a live runner location, center on runner; else center on campus
    final center = runnerPoint ?? _campusCenter;

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 17,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'edu.mahindrauniversity.tomato',
        ),
        // Campus center marker (pickup/dropoff reference)
        CircleLayer(
          circles: [
            CircleMarker(
              point: _campusCenter,
              radius: 14,
              color: AppColors.spaceIndigo.withValues(alpha: 0.1),
              borderColor: AppColors.lavenderGrey,
              borderStrokeWidth: 1.5,
            ),
          ],
        ),
        // Live runner location
        if (runnerPoint != null)
          MarkerLayer(
            markers: [
              Marker(
                point: runnerPoint,
                width: 48,
                height: 48,
                child: _RunnerDot(),
              ),
            ],
          ),
        // Fallback: static campus dot when no runner location yet
        if (runnerPoint == null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: _campusCenter,
                radius: 18,
                color: AppColors.punchRed.withValues(alpha: 0.25),
                borderColor: AppColors.punchRed,
                borderStrokeWidth: 2.5,
              ),
            ],
          ),
      ],
    );
  }
}

class _RunnerDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing ring
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.punchRed.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .scaleXY(begin: 0.8, end: 1.4, duration: 1500.ms, curve: Curves.easeOut)
            .fadeOut(begin: 0.6, duration: 1500.ms),
        // Solid dot
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.punchRed,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.punchRed.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
