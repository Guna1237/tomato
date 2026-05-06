import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key});

  static const _tabs = [
    (Icons.home_rounded, '/home'),
    (Icons.map_outlined, '/assistant'),
    (Icons.add, '/request'),
    (Icons.account_balance_wallet_outlined, '/wallet'),
    (Icons.person_outline_rounded, '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.path;
    final brand = isDark ? const Color(0xFFFF3D52) : AppColors.punchRed;
    const inactive = AppColors.lavenderGrey;
    final bg = isDark
        ? const Color(0xC81A1B2C)
        : const Color(0xC8FFFFFF);

    return Positioned(
      left: 14,
      right: 14,
      bottom: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? const Color(0x14EDF2F4)
                    : const Color(0x0A2B2D42),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final (icon, route) = _tabs[i];
                final isPlus = i == 2;
                final isActive = location == route && !isPlus;

                if (isPlus) {
                  return GestureDetector(
                    onTap: () => context.push('/request'),
                    child: Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: brand,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: brand.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 26),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => context.go(route),
                  child: SizedBox(
                    width: 52,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isActive ? 36 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: brand,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          icon,
                          size: 24,
                          color: isActive ? brand : inactive,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
