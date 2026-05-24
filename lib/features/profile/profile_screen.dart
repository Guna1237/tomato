import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import '../../core/services/face_detection_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/supabase/supabase_client.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/profile_avatar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../data/models/profile.dart';
import 'widgets/reliability_ring.dart';
import 'widgets/badge_grid.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _togglingRunner = false;

  Future<void> _toggleRunnerActive(Profile user, bool newValue) async {
    setState(() => _togglingRunner = true);
    try {
      await supabase
          .from('profiles')
          .update({'runner_active': newValue})
          .eq('id', user.id);
      ref.invalidate(currentUserProvider);
    } finally {
      if (mounted) setState(() => _togglingRunner = false);
    }
  }

  Future<void> _becomeRunner(Profile user) async {
    setState(() => _togglingRunner = true);
    try {
      await supabase
          .from('profiles')
          .update({'is_runner': true, 'runner_active': true})
          .eq('id', user.id);
      ref.invalidate(currentUserProvider);
    } finally {
      if (mounted) setState(() => _togglingRunner = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;

    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          AppStatusBar(dark: isDark),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile', style: AppTextStyles.h1(color: fg1)),
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42),
                      ),
                    ),
                    child: Icon(Icons.settings_outlined, color: fg1, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: userAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (user) {
                if (user == null) {
                  return const Center(child: Text('Not signed in'));
                }
                return _ProfileBody(
                  user: user,
                  isDark: isDark,
                  fg1: fg1,
                  togglingRunner: _togglingRunner,
                  onToggleRunnerActive: (val) => _toggleRunnerActive(user, val),
                  onBecomeRunner: () => _becomeRunner(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBody extends ConsumerStatefulWidget {
  final Profile user;
  final bool isDark;
  final Color fg1;
  final bool togglingRunner;
  final ValueChanged<bool> onToggleRunnerActive;
  final VoidCallback onBecomeRunner;

  const _ProfileBody({
    required this.user,
    required this.isDark,
    required this.fg1,
    required this.togglingRunner,
    required this.onToggleRunnerActive,
    required this.onBecomeRunner,
  });

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  bool _editingName = false;
  bool _savingName = false;
  bool _editingPhone = false;
  bool _savingPhone = false;
  bool _editingRoll = false;
  bool _savingRoll = false;
  bool _uploadingPhoto = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _rollController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _rollController = TextEditingController(text: widget.user.rollNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _rollController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.user.displayName) {
      setState(() => _editingName = false);
      return;
    }
    setState(() => _savingName = true);
    try {
      await supabase
          .from('profiles')
          .update({'display_name': newName})
          .eq('id', widget.user.id);
      ref.invalidate(currentUserProvider);
    } finally {
      if (mounted) {
        setState(() {
          _savingName = false;
          _editingName = false;
        });
      }
    }
  }

  Future<void> _savePhone() async {
    final val = _phoneController.text.trim();
    if (val == (widget.user.phoneNumber ?? '')) {
      setState(() => _editingPhone = false);
      return;
    }
    setState(() => _savingPhone = true);
    try {
      await supabase
          .from('profiles')
          .update({'phone_number': val.isEmpty ? null : val})
          .eq('id', widget.user.id);
      ref.invalidate(currentUserProvider);
    } finally {
      if (mounted) setState(() { _savingPhone = false; _editingPhone = false; });
    }
  }

  Future<void> _saveRoll() async {
    final val = _rollController.text.trim();
    if (val == (widget.user.rollNumber ?? '')) {
      setState(() => _editingRoll = false);
      return;
    }
    setState(() => _savingRoll = true);
    try {
      await supabase
          .from('profiles')
          .update({'roll_number': val.isEmpty ? null : val})
          .eq('id', widget.user.id);
      ref.invalidate(currentUserProvider);
    } finally {
      if (mounted) setState(() { _savingRoll = false; _editingRoll = false; });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_uploadingPhoto) return;
    final picker = ImagePicker();
    XFile? picked;
    try {
      picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
      );
    } catch (_) {
      return;
    }
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final bytes = await picked.readAsBytes();
      final user = supabase.auth.currentUser!;
      final storagePath = '${user.id}/profile.jpg';

      await supabase.storage.from('profile-photos').uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );

      double faceConfidence = 0.0;
      if (!kIsWeb) {
        try {
          faceConfidence = await detectFaceConfidence(picked.path);
        } catch (_) {
          faceConfidence = 0.0;
        }
      }

      await supabase.functions.invoke('validate-identity', body: {
        'user_id': user.id,
        'email': user.email,
        'display_name': widget.user.displayName,
        if (widget.user.rollNumber != null) 'roll_number': widget.user.rollNumber,
        'photo_path': storagePath,
        'face_confidence': faceConfidence,
      });

      ref.invalidate(currentUserProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo updated. It will be reviewed shortly.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final isDark = widget.isDark;
    final fg1 = widget.fg1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        // Profile header card
        TomatoCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Tappable avatar
                  GestureDetector(
                    onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 72, height: 72,
                          child: _uploadingPhoto
                              ? Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.punchRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              : ProfileAvatar(
                                  photoPath: user.photoUrl,
                                  displayName: user.displayName,
                                  radius: 36,
                                  backgroundColor: AppColors.punchRed,
                                  initialsStyle: AppTextStyles.h2(color: Colors.white),
                                ),
                        ),
                        if (!_uploadingPhoto)
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkElevated : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0x22EDF2F4) : const Color(0x14000000),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 12,
                                color: isDark ? AppColors.platinum : AppColors.spaceIndigo,
                              ),
                            ),
                          ),
                        if (user.faceStatus == 'approved')
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 22, height: 22,
                              decoration: const BoxDecoration(
                                color: AppColors.leaf500,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 13),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: _editingName
                                  ? TextField(
                                      controller: _nameController,
                                      autofocus: true,
                                      style: AppTextStyles.h3(color: fg1),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: AppColors.punchRed.withValues(alpha: 0.6),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: AppColors.punchRed,
                                          ),
                                        ),
                                      ),
                                      onSubmitted: (_) => _saveName(),
                                    )
                                  : Text(user.displayName, style: AppTextStyles.h3(color: fg1)),
                            ),
                            if (user.faceStatus == 'approved' && !_editingName) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: AppColors.punchRed, size: 16),
                            ],
                            const SizedBox(width: 4),
                            _savingName
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : GestureDetector(
                                    onTap: _editingName ? _saveName : () {
                                      setState(() => _editingName = true);
                                    },
                                    child: Icon(
                                      _editingName
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.edit_outlined,
                                      size: 18,
                                      color: AppColors.lavenderGrey,
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(user.email, style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42)),
              const SizedBox(height: 12),

              // Editable contact fields
              _EditableField(
                label: 'Roll number',
                controller: _rollController,
                editing: _editingRoll,
                saving: _savingRoll,
                hint: 'e.g. CS2024001',
                keyboardType: TextInputType.text,
                fg1: fg1,
                onEdit: () => setState(() => _editingRoll = true),
                onSave: _saveRoll,
              ),
              const SizedBox(height: 8),
              _EditableField(
                label: 'Phone number',
                controller: _phoneController,
                editing: _editingPhone,
                saving: _savingPhone,
                hint: 'e.g. +91 98765 43210',
                keyboardType: TextInputType.phone,
                fg1: fg1,
                onEdit: () => setState(() => _editingPhone = true),
                onSave: _savePhone,
              ),
              const SizedBox(height: 12),
              Divider(color: isDark ? const Color(0x12EDF2F4) : const Color(0x0A2B2D42)),
              const SizedBox(height: 16),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(value: '${user.streakDays}d', label: 'Streak'),
                  _Stat(value: '🍅${user.tomatoCredits}', label: 'Tomatoes'),
                  _Stat(value: '${(user.reliability * 100).toInt()}%', label: 'Reliability'),
                ],
              ),
            ],
          ),
        ),

        // Face verification banner
        if (user.faceStatus == 'flagged')
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB800)),
            ),
            child: const Row(children: [
              Icon(Icons.access_time_rounded, color: Color(0xFFB37A00), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Identity verification pending - admin will review your photo shortly',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A5200)),
                ),
              ),
            ]),
          ),

        if (user.faceStatus == 'rejected')
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEF233C)),
            ),
            child: const Row(children: [
              Icon(Icons.error_outline_rounded, color: Color(0xFFEF233C), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please re-upload your profile photo for identity verification',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9B0000)),
                ),
              ),
            ]),
          ),

        const SizedBox(height: 24),

        // Runner mode section
        TomatoCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: user.isRunner
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.punchRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.directions_run_rounded, color: AppColors.punchRed, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Available as runner', style: AppTextStyles.bodySmSemibold(color: fg1)),
                            Text('Accept delivery requests from campus', style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                          ],
                        ),
                      ),
                      widget.togglingRunner
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Switch(
                              value: user.runnerActive,
                              onChanged: widget.onToggleRunnerActive,
                              thumbColor: WidgetStateProperty.resolveWith(
                                (s) => s.contains(WidgetState.selected) ? AppColors.punchRed : null,
                              ),
                            ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.lavenderGrey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.directions_run_rounded, color: AppColors.lavenderGrey, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Become a runner', style: AppTextStyles.bodySmSemibold(color: fg1)),
                            Text('Earn tomatos by running deliveries', style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
                          ],
                        ),
                      ),
                      widget.togglingRunner
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : GestureDetector(
                              onTap: widget.onBecomeRunner,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.punchRed,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('Join', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            ),
                    ],
                  ),
                ),
        ),

        const SizedBox(height: 24),

        const SectionHeader(title: 'Reliability'),
        const SizedBox(height: 16),
        Center(child: ReliabilityRing(reliability: user.reliability)),
        const SizedBox(height: 24),

        const SectionHeader(title: 'Badges'),
        const SizedBox(height: 12),
        const BadgeGrid(),
        const SizedBox(height: 24),

        const SectionHeader(title: 'Reviews'),
        const SizedBox(height: 12),
        TomatoCard(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No reviews yet',
              style: AppTextStyles.meta(color: AppColors.lavenderGrey),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool editing;
  final bool saving;
  final String hint;
  final TextInputType keyboardType;
  final Color fg1;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  const _EditableField({
    required this.label,
    required this.controller,
    required this.editing,
    required this.saving,
    required this.hint,
    required this.keyboardType,
    required this.fg1,
    required this.onEdit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: AppTextStyles.meta(color: AppColors.lavenderGrey)),
        ),
        Expanded(
          child: editing
              ? TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: keyboardType,
                  style: AppTextStyles.bodySm(color: fg1),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hint,
                    hintStyle: AppTextStyles.bodySm(color: AppColors.lavenderGrey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.punchRed.withValues(alpha: 0.6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.punchRed),
                    ),
                  ),
                  onSubmitted: (_) => onSave(),
                )
              : Text(
                  controller.text.isEmpty ? hint : controller.text,
                  style: AppTextStyles.bodySm(
                    color: controller.text.isEmpty ? AppColors.lavenderGrey : fg1,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        saving
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : GestureDetector(
                onTap: editing ? onSave : onEdit,
                child: Icon(
                  editing ? Icons.check_circle_outline_rounded : Icons.edit_outlined,
                  size: 18,
                  color: AppColors.lavenderGrey,
                ),
              ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    return Column(
      children: [
        Text(value, style: AppTextStyles.h3(color: fg1)),
        Text(label, style: AppTextStyles.micro(color: AppColors.lavenderGrey)),
      ],
    );
  }
}
