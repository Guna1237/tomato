import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../shared/widgets/tomato_button.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [BackButtonWidget()]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('Step 3 of 4', style: AppTextStyles.micro(color: AppColors.punchRed)),
                  const SizedBox(height: 10),
                  Text('Set up your profile', style: AppTextStyles.h1(color: fg1)),
                  const SizedBox(height: 8),
                  Text(
                    'This helps other students know who you are.',
                    style: AppTextStyles.body(color: AppColors.lavenderGrey),
                  ),
                  const SizedBox(height: 32),

                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFC4B0), Color(0xFFFF8A97)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'RS',
                              style: AppTextStyles.h1(color: Colors.white).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.punchRed,
                              shape: BoxShape.circle,
                              border: Border.all(color: bg, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form fields
                  ...[
                    (Icons.person_outline_rounded, 'FULL NAME', 'Rahul Sharma', true),
                    (Icons.badge_outlined, 'ROLL NUMBER', 'SE21UCSE001', true),
                    (Icons.home_outlined, 'HOSTEL / BLOCK', 'H4 — North Wing', true),
                    (Icons.mail_outline_rounded, 'UNIVERSITY EMAIL', 'ra2211003...@mu.edu.in', false),
                  ].map((f) {
                    final (icon, label, value, verified) = f;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TomatoCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(icon, color: AppColors.lavenderGrey, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(label, style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                                  const SizedBox(height: 2),
                                  Text(value, style: AppTextStyles.bodySmSemibold(color: fg1)),
                                ],
                              ),
                            ),
                            if (verified)
                              const Icon(Icons.check_circle_rounded, color: AppColors.leaf500, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 32),
                  TomatoButton(
                    label: 'Looks good — continue',
                    isFullWidth: true,
                    size: TomatoButtonSize.lg,
                    onTap: () => context.go('/home'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
