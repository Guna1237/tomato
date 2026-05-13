import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/tomato_card.dart';

// Mahindra University, Bahadurpally, Hyderabad
const _campusCenter = LatLng(17.5684696, 78.4362807);

class CampusMapCard extends StatelessWidget {
  const CampusMapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return TomatoCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nearby runners', style: AppTextStyles.h4(color: fg1)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.punchRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Sp.rpill),
                  ),
                  child: Text(
                    'Live',
                    style: AppTextStyles.micro(color: AppColors.punchRed),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(
                      initialCenter: _campusCenter,
                      initialZoom: 16,
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'edu.mahindrauniversity.tomato',
                      ),
                      const MarkerLayer(
                        markers: [
                          Marker(
                            point: _campusCenter,
                            width: 28,
                            height: 28,
                            child: _RedPin(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Pulsing runner dots — use Align, not Positioned+LayoutBuilder
                  ...[
                    (0.25, 0.40, AppColors.punchRed),
                    (0.55, 0.25, AppColors.ember500),
                    (0.70, 0.60, AppColors.leaf500),
                    (0.40, 0.70, AppColors.lavenderGrey),
                  ].map((d) {
                    final (fx, fy, color) = d;
                    return Align(
                      alignment: Alignment(fx * 2 - 1, fy * 2 - 1),
                      child: _PulsingDot(color: color),
                    );
                  }),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.punchRed, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Runners active near campus',
                  style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RedPin extends StatelessWidget {
  const _RedPin();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.location_pin,
      color: AppColors.punchRed,
      size: 28,
    );
  }
}

class _PulsingDot extends StatelessWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(begin: 1.0, end: 1.6, duration: 1500.ms, curve: Curves.easeOut)
              .fadeOut(duration: 1500.ms),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
