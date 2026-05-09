import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/supabase/supabase_client.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../shared/widgets/tomato_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final brand = isDark ? const Color(0xFFFF3D52) : AppColors.punchRed;

    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    final displayName = user?.displayName ?? '';
    final email = user?.email ?? '';
    final initials = user?.initials ?? '?';

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusBar(dark: isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                  child: Text('Settings', style: AppTextStyles.h1(color: fg1)),
                ),

                // Profile chip
                TomatoCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => context.go('/profile'),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.punchRed,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: AppTextStyles.h4(color: fg1)),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: AppTextStyles.meta(
                                color: isDark ? AppColors.lavenderGrey : const Color(0xFF5E6781),
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
                        color: isDark ? AppColors.lavenderGrey : const Color(0xFF5E6781),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const SectionHeader(title: 'Experience'),
                const SizedBox(height: 10),
                TomatoCard(
                  padding: EdgeInsets.zero,
                  child: _SettingsRow(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark mode',
                    isDark: isDark,
                    trailing: Switch.adaptive(
                      value: isDark,
                      onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                      activeThumbColor: brand,
                      activeTrackColor: brand.withValues(alpha: 0.3),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const SectionHeader(title: 'About'),
                const SizedBox(height: 10),
                TomatoCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.info_outline_rounded,
                        label: 'Version',
                        value: '1.0.0',
                        isDark: isDark,
                      ),
                      if (user?.role == 'admin') ...[
                        _Hairline(isDark: isDark),
                        _SettingsRow(
                          icon: Icons.admin_panel_settings_outlined,
                          label: 'Admin dashboard',
                          iconColor: brand,
                          isDark: isDark,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: isDark ? AppColors.lavenderGrey : const Color(0xFF5E6781),
                          ),
                          onTap: () => context.push('/admin'),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                TomatoButton(
                  label: 'Sign out',
                  isFullWidth: true,
                  variant: TomatoButtonVariant.outline,
                  onTap: () => _signOut(context),
                ),

                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'Tomato · Mahindra University',
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

class _Hairline extends StatelessWidget {
  final bool isDark;
  const _Hairline({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      color: isDark ? const Color(0x12EDF2F4) : const Color(0x122B2D42),
    );
  }
}

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
    final fg3 = isDark ? AppColors.lavenderGrey : const Color(0xFF5E6781);
    final resolvedIconColor = iconColor ?? (isDark ? const Color(0xFFC5CCD9) : const Color(0xFF3F4359));

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodySmSemibold(color: fg1)
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                if (value != null) ...[
                  const SizedBox(height: 1),
                  Text(value!,
                      style: AppTextStyles.meta(color: fg3)
                          .copyWith(fontWeight: FontWeight.w500, fontSize: 12)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    if (onTap != null) return InkWell(onTap: onTap, child: content);
    return content;
  }
}
