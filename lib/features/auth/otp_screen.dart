import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_status_bar.dart';
import '../../shared/widgets/back_button_widget.dart';
import '../../shared/widgets/tomato_card.dart';
import '../../core/supabase/supabase_client.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<String> _digits = List.filled(6, '');
  int _secondsLeft = 42;
  Timer? _timer;
  StreamSubscription<AuthState>? _authSub;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Catch session if user clicks the magic link in email instead of typing code
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && mounted && !_isLoading) {
        _handleSignedIn();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleSignedIn() async {
    setState(() => _isLoading = true);
    try {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .maybeSingle();
      if (mounted) {
        if (profile == null) {
          context.go('/profile-setup');
        } else {
          context.go('/home');
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDigit(String d) {
    if (_isLoading) return;
    final idx = _digits.indexOf('');
    if (idx == -1) return;
    setState(() => _digits[idx] = d);
    if (idx == 5) {
      Future.delayed(const Duration(milliseconds: 300), _verifyOtp);
    }
  }

  Future<void> _verifyOtp() async {
    final params = GoRouterState.of(context).uri.queryParameters;
    final email = params['email'] ?? '';
    final mode = params['mode'] ?? '';
    final otpCode = _digits.join();
    setState(() => _isLoading = true);
    try {
      await supabase.auth.verifyOTP(
        email: email,
        token: otpCode,
        type: OtpType.email,
      );
      if (!mounted) return;
      if (mode == 'signup') {
        // New user — always go to profile setup
        context.go('/profile-setup');
        return;
      }
      // Otherwise check if profile exists
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .maybeSingle();
      if (mounted) {
        context.go(profile == null ? '/profile-setup' : '/home');
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase().contains('invalid') ||
                e.toString().toLowerCase().contains('expired')
            ? 'Invalid or expired code — check your email and try again'
            : 'Something went wrong, try again';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.spaceIndigo,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          ),
        );
        setState(() {
          for (int i = 0; i < _digits.length; i++) {
            _digits[i] = '';
          }
          _isLoading = false;
        });
      }
    }
  }

  void _onDelete() {
    final lastFilled = _digits.lastIndexWhere((d) => d.isNotEmpty);
    if (lastFilled >= 0) setState(() => _digits[lastFilled] = '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.platinum : AppColors.spaceIndigo;
    const brand = AppColors.punchRed;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(children: [
      Column(
        children: [
          AppStatusBar(dark: isDark),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [BackButtonWidget()]),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verify email', style: AppTextStyles.micro(color: brand)),
                  const SizedBox(height: 10),
                  Text('Check your inbox', style: AppTextStyles.h1(color: fg1)),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit code to\n${GoRouterState.of(context).uri.queryParameters['email'] ?? ''}',
                    style: AppTextStyles.body(color: AppColors.lavenderGrey),
                  ),
                  const SizedBox(height: 32),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      final filled = _digits[i].isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 48,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: filled ? brand : (isDark ? const Color(0x12EDF2F4) : const Color(0x122B2D42)),
                            width: filled ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            filled ? _digits[i] : '',
                            style: AppTextStyles.h2(color: fg1).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Resend
                  Row(
                    children: [
                      Text(
                        _secondsLeft > 0
                            ? 'Resend in 0:${_secondsLeft.toString().padLeft(2, '0')}'
                            : 'Didn\'t receive it?',
                        style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                      ),
                      if (_secondsLeft == 0) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () async {
                            final params = GoRouterState.of(context).uri.queryParameters;
                            final email = params['email'] ?? '';
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await supabase.auth.resend(
                                type: OtpType.signup,
                                email: email,
                              );
                              setState(() => _secondsLeft = 42);
                              _startTimer();
                            } catch (e) {
                              final msg = e.toString().contains('429') || e.toString().toLowerCase().contains('rate')
                                  ? 'Too many requests — wait a minute before resending'
                                  : 'Could not resend — try again';
                              messenger.showSnackBar(SnackBar(
                                content: Text(msg),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.spaceIndigo,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              ));
                              setState(() => _secondsLeft = 60);
                              _startTimer();
                            }
                          },
                          child: Text(
                            'Resend',
                            style: AppTextStyles.metaSemibold(color: brand),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Trust card
                  TomatoCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.leaf500, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Only Mahindra University emails are allowed.',
                            style: AppTextStyles.meta(color: AppColors.lavenderGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom numpad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                for (final row in [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                  ['', '0', '⌫'],
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: row.map((d) {
                        if (d.isEmpty) return const Expanded(child: SizedBox());
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => d == '⌫' ? _onDelete() : _onDigit(d),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurface : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? const Color(0x22000000)
                                          : const Color(0x062B2D42),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    d,
                                    style: AppTextStyles.h3(color: fg1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      if (_isLoading)
        const ColoredBox(
          color: Color(0x66000000),
          child: Center(child: CircularProgressIndicator()),
        ),
      ]),
    );
  }
}
