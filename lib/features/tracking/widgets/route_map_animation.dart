import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';

// Mahindra University, Survey No 62/1A, Bahadurpally, Jeedimetla, Hyderabad
const _campusCenter = LatLng(17.5873, 78.4414);

class RouteMapAnimation extends StatelessWidget {
  const RouteMapAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: _campusCenter,
        initialZoom: 17,
        interactionOptions: InteractionOptions(
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
