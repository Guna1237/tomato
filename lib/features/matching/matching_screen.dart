import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/status_chip.dart';
import 'widgets/match_graph_animation.dart';
import 'widgets/runner_offer_sheet.dart';

class MatchingScreen extends StatelessWidget {
  const MatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Finding you a helper', style: AppTextStyles.h3(color: fg1)),
                      Text('4 runners nearby', style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                    ],
                  ),
                  const Spacer(),
                  StatusChip(label: 'Matching', tone: ChipTone.matching),
                ],
              ),
            ),
          ),

          // Graph animation fills remaining space
          const Expanded(child: MatchGraphAnimation()),

          // Runner offer sheet at bottom
          const RunnerOfferSheet(),
        ],
      ),
    );
  }
}
