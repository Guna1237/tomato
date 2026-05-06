import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

const _avatarPalette = [
  Color(0xFFA85A2C),
  Color(0xFF2C5FA8),
  Color(0xFF8C2CA8),
  Color(0xFF2CA868),
  Color(0xFFA8A82C),
  Color(0xFFA82C5F),
  Color(0xFF2CA8A8),
  Color(0xFF5F2CA8),
];

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;
  final bool showRing;
  final Color? ringColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.backgroundColor,
    this.showRing = false,
    this.ringColor,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name[0].toUpperCase();
  }

  Color get _bgColor =>
      backgroundColor ?? _avatarPalette[name.codeUnitAt(0) % _avatarPalette.length];

  @override
  Widget build(BuildContext context) {
    final avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: AppTextStyles.metaSemibold(color: Colors.white).copyWith(
            fontSize: size * 0.34,
          ),
        ),
      ),
    );

    if (!showRing) return avatarWidget;

    final ring = ringColor ?? const Color(0xFFEF233C);
    return Container(
      width: size + 4,
      height: size + 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2),
      ),
      child: avatarWidget,
    );
  }
}
