import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/supabase/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Displays a circular avatar from a private Storage path or full URL.
/// Falls back to an initials circle while loading or on error.
class ProfileAvatar extends StatefulWidget {
  final String? photoPath;
  final String displayName;
  final double radius;
  final Color? backgroundColor;
  final TextStyle? initialsStyle;

  const ProfileAvatar({
    super.key,
    required this.photoPath,
    required this.displayName,
    this.radius = 24,
    this.backgroundColor,
    this.initialsStyle,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  Future<String?>? _urlFuture;

  @override
  void initState() {
    super.initState();
    _urlFuture = signedPhotoUrl(widget.photoPath);
  }

  @override
  void didUpdateWidget(ProfileAvatar old) {
    super.didUpdateWidget(old);
    if (old.photoPath != widget.photoPath) {
      _urlFuture = signedPhotoUrl(widget.photoPath);
    }
  }

  String get _initial {
    final name = widget.displayName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ??
        AppColors.punchRed.withValues(alpha: 0.15);
    final textStyle = widget.initialsStyle ??
        AppTextStyles.bodySm(color: AppColors.punchRed);

    if (widget.photoPath == null) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: bg,
        child: Text(_initial, style: textStyle),
      );
    }

    return FutureBuilder<String?>(
      future: _urlFuture,
      builder: (context, snap) {
        if (snap.hasData && snap.data != null) {
          return CircleAvatar(
            radius: widget.radius,
            backgroundColor: bg,
            backgroundImage: CachedNetworkImageProvider(snap.data!),
            onBackgroundImageError: (_, __) {},
          );
        }
        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: bg,
          child: Text(_initial, style: textStyle),
        );
      },
    );
  }
}
