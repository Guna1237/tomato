import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/profile_setup_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/wallet/wallet_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/request/request_screen.dart';
import '../../features/matching/matching_screen.dart';
import '../../features/tracking/tracking_screen.dart';
import '../../features/emergency/emergency_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/admin/admin_screen.dart';
import '../../features/runner/runner_screen.dart';
import '../../shared/widgets/app_tab_bar.dart';

Widget _slideUp(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) {
  return SlideTransition(
    position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    ),
    child: child,
  );
}

Widget _slideRight(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) {
  return SlideTransition(
    position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Cubic(0.3, 0.9, 0.1, 1),
      ),
    ),
    child: child,
  );
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isPublic = ['/splash', '/onboarding', '/login', '/otp', '/profile-setup', '/reset-password']
        .any((r) => state.matchedLocation.startsWith(r));
    if (session == null && !isPublic) return '/login';
    if (session != null && (state.matchedLocation == '/login' || state.matchedLocation == '/onboarding')) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (_, state) => NoTransitionPage(child: const SplashScreen(), key: state.pageKey),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
        transitionsBuilder: _slideRight,
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: _slideRight,
      ),
    ),
    GoRoute(
      path: '/otp',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OtpScreen(),
        transitionsBuilder: _slideRight,
      ),
    ),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ResetPasswordScreen(),
        transitionsBuilder: _slideRight,
      ),
    ),
    GoRoute(
      path: '/profile-setup',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfileSetupScreen(),
        transitionsBuilder: _slideRight,
      ),
    ),

    // Main shell with persistent tab bar
    ShellRoute(
      builder: (context, state, child) => _MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (_, state) => NoTransitionPage(child: const HomeScreen(), key: state.pageKey),
        ),
        GoRoute(
          path: '/assistant',
          pageBuilder: (_, state) => NoTransitionPage(child: const AssistantScreen(), key: state.pageKey),
        ),
        GoRoute(
          path: '/wallet',
          pageBuilder: (_, state) => NoTransitionPage(child: const WalletScreen(), key: state.pageKey),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, state) => NoTransitionPage(child: const ProfileScreen(), key: state.pageKey),
        ),
      ],
    ),

    // Notifications — push from home bell icon
    GoRoute(
      path: '/notifications',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const NotificationsScreen(),
        transitionsBuilder: _slideRight,
      ),
    ),

    // Full-screen flows
    GoRoute(
      path: '/request',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RequestScreen(),
        transitionsBuilder: _slideUp,
      ),
    ),
    GoRoute(
      path: '/matching',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MatchingScreen(),
        transitionsBuilder: _slideUp,
      ),
    ),
    GoRoute(
      path: '/tracking',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const TrackingScreen(),
        transitionsBuilder: _slideRight,
      ),
    ),
    GoRoute(
      path: '/emergency',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const EmergencyScreen(),
        transitionsBuilder: _slideUp,
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: _slideRight,
      ),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AdminScreen(),
        transitionsBuilder: _slideRight,
      ),
    ),
    GoRoute(
      path: '/runner',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RunnerScreen(),
        transitionsBuilder: _slideRight,
      ),
    ),
  ],
);

class _MainShell extends ConsumerWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentUserProvider).whenData((profile) {
      if (profile == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/profile-setup');
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1.0).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(GoRouterState.of(context).uri.path),
              child: child,
            ),
          ),
          const AppTabBar(),
        ],
      ),
    );
  }
}
