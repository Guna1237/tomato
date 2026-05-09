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
  bool _isSignUp = false;
  bool _isLoading = false;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;

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
          _confirmCtrl.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool _validEmail(String email) =>
      email.trim().toLowerCase().endsWith('@mahindrauniversity.edu.in');

  // Sign in: email + password
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

  // Sign up: email + password + confirm → send OTP → verify → profile setup
  Future<void> _signUp() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (!_validEmail(email)) {
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
      // signUp creates the account with a password AND sends OTP to verify email
      await supabase.auth.signUp(email: email, password: password);
      if (mounted) {
        context.go('/otp?email=${Uri.encodeComponent(email)}&mode=signup');
      }
    } catch (e) {
      if (mounted) _showError(_friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Forgot / set password: sends a magic link / OTP for password reset
  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    if (!_validEmail(email)) {
      _showError('Enter your MU email above first');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await supabase.auth.resetPasswordForEmail(email);
      if (mounted) {
        _showInfo('Password reset link sent to $email');
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
    if (r.contains('already registered') || r.contains('user already')) {
      return 'Account already exists — sign in instead';
    }
    if (r.contains('email not confirmed')) {
      return 'Check your email inbox for the verification code';
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

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.leaf500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  InputDecoration _field({required String hint, Widget? suffix}) {
    return InputDecoration(
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
  }

  Widget _eyeIcon(bool visible, VoidCallback toggle) => IconButton(
        icon: Icon(
          visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.lavenderGrey,
          size: 20,
        ),
        onPressed: toggle,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Logo
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

                    // Tab switcher
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: const Border.fromBorderSide(
                            BorderSide(color: Color(0xFFE8EAF0))),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.lavenderGrey,
                        labelStyle: AppTextStyles.bodySmSemibold(
                            color: Colors.white),
                        unselectedLabelStyle:
                            AppTextStyles.bodySm(color: AppColors.lavenderGrey),
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

                    Text(
                      _isSignUp ? 'Create account' : 'Welcome back',
                      style:
                          AppTextStyles.h1(color: AppColors.spaceIndigo),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSignUp
                          ? 'Choose a password — we\'ll verify your email with a code'
                          : 'Sign in to your university account',
                      style:
                          AppTextStyles.body(color: AppColors.lavenderGrey),
                    ),

                    const SizedBox(height: 24),

                    // Email
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: AppTextStyles.body(color: AppColors.spaceIndigo),
                      decoration: _field(
                          hint: 'rollnumber@mahindrauniversity.edu.in'),
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: !_showPassword,
                      style: AppTextStyles.body(color: AppColors.spaceIndigo),
                      decoration: _field(
                        hint: 'Password',
                        suffix: _eyeIcon(_showPassword,
                            () => setState(() => _showPassword = !_showPassword)),
                      ),
                    ),

                    // Confirm password — sign up only
                    if (_isSignUp) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmCtrl,
                        obscureText: !_showConfirm,
                        style:
                            AppTextStyles.body(color: AppColors.spaceIndigo),
                        decoration: _field(
                          hint: 'Confirm password',
                          suffix: _eyeIcon(_showConfirm,
                              () => setState(() => _showConfirm = !_showConfirm)),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    TomatoButton(
                      label: _isSignUp ? 'Continue' : 'Sign in',
                      isFullWidth: true,
                      size: TomatoButtonSize.lg,
                      isLoading: _isLoading,
                      onTap: _isLoading
                          ? null
                          : (_isSignUp ? _signUp : _signIn),
                    ),

                    // Forgot password — sign in tab only
                    if (!_isSignUp) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: _isLoading ? null : _forgotPassword,
                          child: Text(
                            'Forgot password? Send reset link',
                            style: AppTextStyles.meta(
                                color: AppColors.punchRed),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Previously signed in with OTP? Use "Forgot password" to set one.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.meta(
                              color: AppColors.lavenderGrey),
                        ),
                      ),
                    ],

                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.mail_outline_rounded,
                              size: 16, color: AppColors.lavenderGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A 6-digit verification code will be sent to your MU email',
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
