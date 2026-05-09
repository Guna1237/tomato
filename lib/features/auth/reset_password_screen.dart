import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/tomato_logo.dart';
import '../../shared/widgets/tomato_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show UserAttributes;
import '../../core/supabase/supabase_client.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _isLoading = false;
  bool _done = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (password.length < 6) {
      _showErr('Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      _showErr('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.updateUser(UserAttributes(password: password));
      if (mounted) {
        setState(() { _done = true; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        _showErr('Could not update password — the link may have expired');
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.spaceIndigo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    ));
  }

  InputDecoration _field({required String hint, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(
            color: AppColors.lavenderGrey.withValues(alpha: 0.7)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EAF0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EAF0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.punchRed, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.punchRed, Color(0xFFFF6A55)]),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        const TomatoMark(size: 40),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('tomato',
                                style: AppTextStyles.h2(
                                    color: AppColors.spaceIndigo)),
                            Text('MU campus delivery',
                                style: AppTextStyles.micro(
                                    color: AppColors.lavenderGrey)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    if (_done) ...[
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.leaf500, size: 48),
                      const SizedBox(height: 16),
                      Text('Password updated',
                          style:
                              AppTextStyles.h1(color: AppColors.spaceIndigo)),
                      const SizedBox(height: 8),
                      Text('You can now sign in with your new password.',
                          style: AppTextStyles.body(
                              color: AppColors.lavenderGrey)),
                      const SizedBox(height: 32),
                      TomatoButton(
                        label: 'Go to sign in',
                        isFullWidth: true,
                        size: TomatoButtonSize.lg,
                        onTap: () => context.go('/login'),
                      ),
                    ] else ...[
                      Text('Set new password',
                          style:
                              AppTextStyles.h1(color: AppColors.spaceIndigo)),
                      const SizedBox(height: 8),
                      Text('Choose a password for your Tomato account.',
                          style: AppTextStyles.body(
                              color: AppColors.lavenderGrey)),
                      const SizedBox(height: 28),

                      TextField(
                        controller: _passwordCtrl,
                        obscureText: !_showPassword,
                        style:
                            AppTextStyles.body(color: AppColors.spaceIndigo),
                        decoration: _field(
                          hint: 'New password',
                          suffix: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.lavenderGrey,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _showPassword = !_showPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmCtrl,
                        obscureText: !_showConfirm,
                        style:
                            AppTextStyles.body(color: AppColors.spaceIndigo),
                        decoration: _field(
                          hint: 'Confirm password',
                          suffix: IconButton(
                            icon: Icon(
                              _showConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.lavenderGrey,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _showConfirm = !_showConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TomatoButton(
                        label: 'Update password',
                        isFullWidth: true,
                        size: TomatoButtonSize.lg,
                        isLoading: _isLoading,
                        onTap: _isLoading ? null : _submit,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
