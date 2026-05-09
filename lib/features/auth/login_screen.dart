import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/tomato_logo.dart';
import '../../shared/widgets/tomato_button.dart';
import '../../core/supabase/supabase_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;

    if (!email.endsWith('@mahindrauniversity.edu.in')) {
      _showError('Must be a @mahindrauniversity.edu.in address');
      return;
    }
    if (password.isEmpty) {
      _showError('Enter your password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) _showError(_friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (!email.endsWith('@mahindrauniversity.edu.in')) {
      _showError('Must be a @mahindrauniversity.edu.in address');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signUp(email: email, password: password);
      if (mounted) context.go('/profile-setup');
    } catch (e) {
      if (mounted) _showError(_friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login')) return 'Incorrect email or password';
    if (raw.contains('already registered')) return 'Account already exists — sign in instead';
    if (raw.contains('Email not confirmed')) return 'Check your email to confirm your account';
    return 'Something went wrong, try again';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.spaceIndigo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  InputDecoration _field({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body(
        color: AppColors.lavenderGrey.withValues(alpha: 0.7),
      ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: Column(
        children: [
          // Thin red accent bar at top
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.punchRed, Color(0xFFFF6A55)],
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Logo row: mark + wordmark left-aligned
                    Row(
                      children: [
                        const TomatoMark(size: 40),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'tomato',
                              style: AppTextStyles.h2(
                                color: AppColors.spaceIndigo,
                              ),
                            ),
                            Text(
                              'MU campus delivery',
                              style: AppTextStyles.micro(
                                color: AppColors.lavenderGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Heading
                    Text(
                      _isSignUp ? 'Create account' : 'Welcome back',
                      style: AppTextStyles.h1(color: AppColors.spaceIndigo),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSignUp
                          ? 'Use your university email to get started'
                          : 'Sign in to your university account',
                      style: AppTextStyles.body(color: AppColors.lavenderGrey),
                    ),

                    const SizedBox(height: 28),

                    // Email field
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: AppTextStyles.body(color: AppColors.spaceIndigo),
                      decoration: _field(
                        hint: 'rollnumber@mahindrauniversity.edu.in',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password field
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: !_showPassword,
                      style: AppTextStyles.body(color: AppColors.spaceIndigo),
                      decoration: _field(
                        hint: 'Password',
                        suffix: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.lavenderGrey,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),

                    // Confirm password (sign-up only)
                    if (_isSignUp) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmCtrl,
                        obscureText: !_showConfirm,
                        style: AppTextStyles.body(color: AppColors.spaceIndigo),
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
                            onPressed: () =>
                                setState(() => _showConfirm = !_showConfirm),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    TomatoButton(
                      label: _isSignUp ? 'Create account' : 'Sign in',
                      isFullWidth: true,
                      size: TomatoButtonSize.lg,
                      isLoading: _isLoading,
                      onTap: _isLoading ? null : (_isSignUp ? _signUp : _signIn),
                    ),

                    const SizedBox(height: 20),

                    // Toggle row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp ? 'Already have an account?' : 'New here?',
                          style: AppTextStyles.bodySm(
                            color: AppColors.lavenderGrey,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _emailCtrl.clear();
                              _passwordCtrl.clear();
                              _confirmCtrl.clear();
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.punchRed,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            _isSignUp ? 'Sign in' : 'Create account',
                            style: AppTextStyles.bodySmSemibold(
                              color: AppColors.punchRed,
                            ),
                          ),
                        ),
                      ],
                    ),
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
