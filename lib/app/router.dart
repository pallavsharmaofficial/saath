import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_state.dart';
import '../features/counsellor/counsellor_screen.dart';
import '../features/couple/couple_space_screen.dart';
import '../features/home/today_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/onboarding/onboarding_screens.dart';
import '../features/repair/repair_screens.dart';
import '../features/safety/safety_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/untangle/untangle_screen.dart';
import 'shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(appStateProvider.select((s) => s.onboarded));

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: onboarded ? '/' : '/onboarding',
    redirect: (context, state) {
      final inOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (!onboarded && !inOnboarding) return '/onboarding';
      if (onboarded && inOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (c, s) => _fade(const WelcomeScreen(), s),
        routes: [
          GoRoute(path: 'names', pageBuilder: (c, s) => _fade(const NamesScreen(), s)),
          GoRoute(path: 'origin', pageBuilder: (c, s) => _fade(const OriginStoryScreen(), s)),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (c, s) => const TodayScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/counsellor', builder: (c, s) => const CounsellorScreen(embedded: true)),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/us', builder: (c, s) => const CoupleSpaceScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/learn', builder: (c, s) => const LearnScreen())]),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/untangle',
        pageBuilder: (c, s) => _fade(UntangleScreen(vent: (s.extra as String?) ?? ''), s),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/repair',
        pageBuilder: (c, s) => _fade(const RepairIntroScreen(), s),
        routes: [
          GoRoute(
            path: 'merged',
            pageBuilder: (c, s) => _fade(
              RepairMergedScreen(sides: (s.extra as ({String a, String b})?) ?? (a: '', b: '')),
              s,
            ),
          ),
          GoRoute(path: 'cooldown', pageBuilder: (c, s) => _fade(const CoolDownScreen(), s)),
          GoRoute(path: 'close', pageBuilder: (c, s) => _fade(const RepairCloseScreen(), s)),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/talk',
        pageBuilder: (c, s) => _fade(CounsellorScreen(seed: s.extra as String?), s),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/safety', pageBuilder: (c, s) => _fade(const SafetyScreen(), s)),
      GoRoute(parentNavigatorKey: _rootKey, path: '/settings', pageBuilder: (c, s) => _fade(const SettingsScreen(), s)),
    ],
  );
});

/// Cross-fade between atmospheres — a push slide would tear the photo layer.
CustomTransitionPage<void> _fade(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}
