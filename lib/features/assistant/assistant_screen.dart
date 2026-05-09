import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../shared/widgets/tomato_button.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final brand = isDark ? const Color(0xFFFF3D52) : AppColors.punchRed;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),

          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sparkle icon with gradient bg
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [brand, AppColors.ember500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Tomato sense', style: AppTextStyles.h3(color: fg1)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Chat area ───────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const SizedBox(height: 4),

                // User bubble (right-aligned)
                _UserBubble(
                  text: "I'm stuck in lab till 6. Can someone bring my parcel to H4?",
                  brand: brand,
                ),
                const SizedBox(height: 12),

                // AI response column
                _AIResponseColumn(isDark: isDark, brand: brand),
                const SizedBox(height: 12),

                // Green info chip
                _InfoChip(),
              ],
            ),
          ),

          // ── Suggestion chips ────────────────────────────────────────────
          _SuggestionChips(isDark: isDark),

          // ── Composer ────────────────────────────────────────────────────
          _Composer(isDark: isDark, brand: brand),
        ],
      ),
    );
  }
}

// ── User message bubble ─────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final String text;
  final Color brand;

  const _UserBubble({required this.text, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: brand,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Text(
            text,
            style: AppTextStyles.bodySm(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ── AI response (bubble + action card) ─────────────────────────────────────

class _AIResponseColumn extends StatelessWidget {
  final bool isDark;
  final Color brand;

  const _AIResponseColumn({required this.isDark, required this.brand});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.bgSurface;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    final fg3 = isDark ? AppColors.lavenderGrey : const Color(0xFF5E6781);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0x33000000)
                        : const Color(0x082B2D42),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                "Got it. I'll set up a pickup at the South Gate desk and aim for handoff to H4 around 6:10. Two helpers are already near the gate, Priya can be there in 4 minutes.",
                style: AppTextStyles.bodySm(color: fg1),
              ),
            ),

            const SizedBox(height: 8),

            // Action card
            TomatoCard(
              padding: const EdgeInsets.all(14),
              borderRadius: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card header
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0x33FF3D52)
                              : const Color(0x14EF233C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 14,
                          color: brand,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Draft request',
                        style: AppTextStyles.metaSemibold(color: fg1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 2-column info grid
                  _InfoGrid(fg1: fg1, fg3: fg3),

                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TomatoButton(
                          label: 'Send it',
                          variant: TomatoButtonVariant.primary,
                          size: TomatoButtonSize.sm,
                          isFullWidth: true,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      TomatoButton(
                        label: 'Edit',
                        variant: TomatoButtonVariant.outline,
                        size: TomatoButtonSize.sm,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final Color fg1;
  final Color fg3;

  const _InfoGrid({required this.fg1, required this.fg3});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('From', 'South Gate · parcel desk'),
      ('To', 'H4 · 412 (you)'),
      ('By', '6:10 PM'),
      ('Cost', '~T40'),
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < items.length ? 6 : 0),
            child: Row(
              children: [
                Expanded(
                  child: _InfoCell(
                    label: items[i].$1,
                    value: items[i].$2,
                    fg1: fg1,
                    fg3: fg3,
                  ),
                ),
                if (i + 1 < items.length)
                  Expanded(
                    child: _InfoCell(
                      label: items[i + 1].$1,
                      value: items[i + 1].$2,
                      fg1: fg1,
                      fg3: fg3,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final Color fg1;
  final Color fg3;

  const _InfoCell({
    required this.label,
    required this.value,
    required this.fg1,
    required this.fg3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.micro(color: fg3)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.meta(color: fg1)),
      ],
    );
  }
}

// ── Green info chip ──────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1A3FA85B),
        borderRadius: BorderRadius.circular(Sp.rlg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.leaf600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Gate is calm right now - under 2 min wait.',
              style: AppTextStyles.meta(color: AppColors.leaf600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suggestion chips ─────────────────────────────────────────────────────────

class _SuggestionChips extends StatelessWidget {
  final bool isDark;

  const _SuggestionChips({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final chips = [
      "What's at the gate?",
      "Help Priya tonight",
      "Mute until 9 PM",
    ];
    final surface = isDark ? AppColors.darkSurface : AppColors.bgSurface;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(Sp.rpill),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x33000000)
                    : const Color(0x082B2D42),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            chips[i],
            style: AppTextStyles.meta(color: fg1).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Composer ─────────────────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  final bool isDark;
  final Color brand;

  const _Composer({required this.isDark, required this.brand});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.bgSurface;
    final sunken = isDark ? AppColors.darkSunken : AppColors.bgSunken;
    final fg2 = isDark ? const Color(0xFFC5CCD9) : const Color(0xFF3F4359);
    final fg3 = isDark ? AppColors.lavenderGrey : const Color(0xFF5E6781);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 12, 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0x44000000)
                  : const Color(0x0E2B2D42),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Text field
            Expanded(
              child: TextField(
                style: AppTextStyles.bodySm(color: fg2),
                decoration: InputDecoration(
                  hintText: 'Ask, or just describe what you need…',
                  hintStyle: AppTextStyles.bodySm(color: fg3),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            // Mic button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: sunken,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic_none_rounded,
                size: 18,
                color: fg2,
              ),
            ),
            const SizedBox(width: 6),
            // Send button
            Container(
              width: 36,
              height: 36,
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
              child: const Icon(
                Icons.arrow_upward_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
