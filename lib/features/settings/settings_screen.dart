import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/theme_provider.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../shared/widgets/tomato_button.dart';
import '../../data/mock/mock_user.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final brand = isDark ? const Color(0xFFFF3D52) : AppColors.punchRed;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusBar(dark: isDark),

          // ── Header ──────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                  child: Text('Settings', style: AppTextStyles.h1(color: fg1)),
                ),

                // ── Profile chip ─────────────────────────────────────────
                TomatoCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Gradient avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFC4B0), Color(0xFFFF8794)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            mockCurrentUser.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name + email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mockCurrentUser.name,
                              style: AppTextStyles.h4(color: fg1),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mockCurrentUser.email,
                              style: AppTextStyles.meta(
                                color: isDark
                                    ? AppColors.lavenderGrey
                                    : const Color(0xFF5E6781),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.lavenderGrey
                            : const Color(0xFF5E6781),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Section 1: Account ───────────────────────────────────
                const SectionHeader(title: 'Account'),
                const SizedBox(height: 10),
                TomatoCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Profile & verification',
                        value: 'Verified · CSE 3rd year',
                        trailing: _ChevR(),
                        isDark: isDark,
                      ),
                      _Hairline(isDark: isDark),
                      _SettingsRow(
                        icon: Icons.shield_outlined,
                        label: 'Trust & privacy',
                        value: 'Auto-share ETA',
                        trailing: _ChevR(),
                        isDark: isDark,
                      ),
                      _Hairline(isDark: isDark),
                      _SettingsRow(
                        icon: Icons.phone_outlined,
                        label: 'Contact & emergency',
                        value: '+91 ····· 4523',
                        trailing: _ChevR(),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Section 2: Availability ──────────────────────────────
                const SectionHeader(title: 'Availability'),
                const SizedBox(height: 10),
                TomatoCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.directions_walk,
                        label: 'Helper mode',
                        value: 'Available',
                        trailing: Switch.adaptive(
                          value: true,
                          onChanged: (_) {},
                          activeThumbColor: isDark
                              ? const Color(0xFFFF3D52)
                              : AppColors.punchRed,
                          activeTrackColor: (isDark
                                  ? const Color(0xFFFF3D52)
                                  : AppColors.punchRed)
                              .withValues(alpha: 0.3),
                        ),
                        isDark: isDark,
                      ),
                      _Hairline(isDark: isDark),
                      _SettingsRow(
                        icon: Icons.pin_drop_outlined,
                        label: 'Default pickup',
                        value: 'South Gate',
                        trailing: _ChevR(),
                        isDark: isDark,
                      ),
                      _Hairline(isDark: isDark),
                      _SettingsRow(
                        icon: Icons.access_time_rounded,
                        label: 'Quiet hours',
                        value: '10 PM – 7 AM',
                        trailing: _ChevR(),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Section 3: Experience ────────────────────────────────
                const SectionHeader(title: 'Experience'),
                const SizedBox(height: 10),
                TomatoCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.dark_mode_outlined,
                        label: 'Appearance',
                        value: 'Auto',
                        trailing: _ChevR(),
                        isDark: isDark,
                        onTap: () =>
                            ref.read(themeModeProvider.notifier).toggle(),
                      ),
                      _Hairline(isDark: isDark),
                      _SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notifications',
                        value: 'Conversational',
                        trailing: _ChevR(),
                        isDark: isDark,
                      ),
                      _Hairline(isDark: isDark),
                      _SettingsRow(
                        icon: Icons.auto_awesome,
                        label: 'Tomato sense (AI)',
                        value: 'On',
                        trailing: Switch.adaptive(
                          value: true,
                          onChanged: (_) {},
                          activeThumbColor: isDark
                              ? const Color(0xFFFF3D52)
                              : AppColors.punchRed,
                          activeTrackColor: (isDark
                                  ? const Color(0xFFFF3D52)
                                  : AppColors.punchRed)
                              .withValues(alpha: 0.3),
                        ),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Section 4: About ─────────────────────────────────────
                const SectionHeader(title: 'About'),
                const SizedBox(height: 10),
                TomatoCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.info_outline_rounded,
                        label: 'Version',
                        value: '1.4.2 · 2026.05',
                        isDark: isDark,
                      ),
                      _Hairline(isDark: isDark),
                      _SettingsRow(
                        icon: Icons.menu_book_outlined,
                        label: 'Community guidelines',
                        trailing: _ChevR(),
                        isDark: isDark,
                      ),
                      _Hairline(isDark: isDark),
                      _SettingsRow(
                        icon: Icons.warning_amber_rounded,
                        label: 'Report an issue',
                        trailing: _ChevR(),
                        isDark: isDark,
                      ),
                      _Hairline(isDark: isDark),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark
                            ? const Color(0x12EDF2F4)
                            : const Color(0x122B2D42),
                      ),
                      _SettingsRow(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Admin dashboard',
                        iconColor: brand,
                        trailing: _ChevR(),
                        isDark: isDark,
                        onTap: () => context.push('/admin'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Sign out ─────────────────────────────────────────────
                TomatoButton(
                  label: 'Sign out',
                  isFullWidth: true,
                  variant: TomatoButtonVariant.outline,
                  onTap: () => context.go('/login'),
                ),

                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'Tomato v1.4.2 · Mahindra University',
                    style: AppTextStyles.micro(
                      color: AppColors.lavenderGrey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hairline divider helper ──────────────────────────────────────────────────

class _Hairline extends StatelessWidget {
  final bool isDark;
  const _Hairline({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 0,
      color: isDark
          ? const Color(0x12EDF2F4)
          : const Color(0x122B2D42),
    );
  }
}

// ── ChevronRight helper ───────────────────────────────────────────────────────

class _ChevR extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      Icons.chevron_right_rounded,
      size: 18,
      color: isDark ? AppColors.lavenderGrey : const Color(0xFF5E6781),
    );
  }
}

// ── Settings row ─────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final Color? iconColor;
  final bool isDark;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.iconColor,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sunken = isDark ? AppColors.darkSunken : AppColors.bgSunken;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final fg2 = isDark ? const Color(0xFFC5CCD9) : const Color(0xFF3F4359);
    final fg3 = isDark ? AppColors.lavenderGrey : const Color(0xFF5E6781);
    final resolvedIconColor = iconColor ?? fg2;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: sunken,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: resolvedIconColor),
          ),
          const SizedBox(width: 12),
          // Label + optional value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmSemibold(color: fg1).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    value!,
                    style: AppTextStyles.meta(color: fg3).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Trailing widget
          if (trailing != null) trailing!,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
