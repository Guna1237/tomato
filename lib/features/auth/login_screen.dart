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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // false = sign in (password), true = sign up (OTP)
  bool _isSignUp = false;
  bool _isLoading = false;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _isSignUp = _tabController.index == 1;
          _emailCtrl.clear();
          _passwordCtrl.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool _validEmail(String email) =>
      email.trim().toLowerCase().endsWith('@mahindrauniversity.edu.in');

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;

    if (!_validEmail(email)) {
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

  // Sign up sends OTP to email — no password needed for first-time users
  Future<void> _signUp() async {
    final email = _emailCtrl.text.trim().toLowerCase();

    if (!_validEmail(email)) {
      _showError('Must be a @mahindrauniversity.edu.in address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        emailRedirectTo: null,
      );
      if (mounted) {
        context.go('/otp?email=${Uri.encodeComponent(email)}');
      }
    } catch (e) {
      if (mounted) _showError(_friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String raw) {
    final r = raw.toLowerCase();
    if (r.contains('invalid login') || r.contains('invalid credentials')) {
      return 'Incorrect email or password';
    }
    if (r.contains('email not confirmed')) {
      return 'Check your email to confirm your account';
    }
    if (r.contains('rate') || r.contains('429')) {
      return 'Too many attempts — wait a minute and try again';
    }
    if (r.contains('network') || r.contains('socket')) {
      return 'No connection — check your internet';
    }
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
          // Thin red accent bar
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

                    // Logo row
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

                    const SizedBox(height: 36),

                    // Tab switcher: Sign in / Sign up
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: const Border.fromBorderSide(
                          BorderSide(color: Color(0xFFE8EAF0)),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelStyle: AppTextStyles.bodySmSemibold(
                            color: Colors.white),
                        unselectedLabelStyle: AppTextStyles.bodySm(
                            color: AppColors.lavenderGrey),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.lavenderGrey,
                        indicator: BoxDecoration(
                          color: AppColors.punchRed,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        padding: const EdgeInsets.all(4),
                        tabs: const [
                          Tab(text: 'Sign in'),
                          Tab(text: 'Sign up'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Heading changes with tab
                    Text(
                      _isSignUp ? 'Create account' : 'Welcome back',
                      style: AppTextStyles.h1(color: AppColors.spaceIndigo),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSignUp
                          ? 'Enter your university email — we\'ll send you a one-time code'
                          : 'Sign in to your university account',
                      style: AppTextStyles.body(color: AppColors.lavenderGrey),
                    ),

                    const SizedBox(height: 24),

                    // Email field (always shown)
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: AppTextStyles.body(color: AppColors.spaceIndigo),
                      decoration: _field(
                        hint: 'rollnumber@mahindrauniversity.edu.in',
                      ),
                    ),

                    // Password field — sign in only
                    if (!_isSignUp) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: !_showPassword,
                        style:
                            AppTextStyles.body(color: AppColors.spaceIndigo),
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
                            onPressed: () => setState(
                                () => _showPassword = !_showPassword),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    TomatoButton(
                      label: _isSignUp ? 'Send code' : 'Sign in',
                      isFullWidth: true,
                      size: TomatoButtonSize.lg,
                      isLoading: _isLoading,
                      onTap: _isLoading
                          ? null
                          : (_isSignUp ? _signUp : _signIn),
                    ),

                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.mail_outline_rounded,
                              size: 16, color: AppColors.lavenderGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A 6-digit code will be sent to your MU email inbox',
                              style: AppTextStyles.meta(
                                  color: AppColors.lavenderGrey),
                            ),
                          ),
                        ],
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
