import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/tomato_logo.dart';
import '../../shared/widgets/tomato_button.dart';
import '../../shared/widgets/app_status_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() {
      final valid = _emailCtrl.text.contains('@mahindrauniversity.edu.in') &&
          _emailCtrl.text.length > 20;
      if (valid != _isValid) setState(() => _isValid = valid);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const TomatoLogo(size: 36),
                  const SizedBox(height: 48),

                  Text(
                    'Step 1 of 4',
                    style: AppTextStyles.micro(color: AppColors.punchRed),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Your university\nemail',
                    style: AppTextStyles.h1(color: fg1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll verify you\'re a real student.',
                    style: AppTextStyles.body(color: AppColors.lavenderGrey),
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    style: AppTextStyles.body(color: fg1),
                    decoration: InputDecoration(
                      hintText: 'rollnumber@mahindrauniversity.edu.in',
                      hintStyle: AppTextStyles.body(
                        color: AppColors.lavenderGrey.withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.mail_outline_rounded,
                        color: AppColors.lavenderGrey,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  AnimatedOpacity(
                    opacity: _emailCtrl.text.isNotEmpty && !_isValid ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Must end with @mahindrauniversity.edu.in',
                        style: AppTextStyles.meta(color: AppColors.punchRed),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  TomatoButton(
                    label: 'Send verification code',
                    isFullWidth: true,
                    size: TomatoButtonSize.lg,
                    onTap: _isValid ? () => context.go('/otp') : null,
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with demo',
                          style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TomatoButton(
                    label: 'Skip — use demo account',
                    isFullWidth: true,
                    variant: TomatoButtonVariant.secondary,
                    size: TomatoButtonSize.md,
                    onTap: () => context.go('/home'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
