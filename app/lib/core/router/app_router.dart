import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/advisor/presentation/advisor_screen.dart';
import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_account_screen.dart';
import '../../features/auth/presentation/register_farm_screen.dart';
import '../../features/diagnosis/presentation/capture_screen.dart';
import '../../features/diagnosis/presentation/result_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/planner/presentation/planner_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../widgets/main_shell.dart';
import 'auth_guard.dart';
import 'route_names.dart';

/// Global navigator key for top-level modal and standalone route navigation.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');

/// Provider for the application [GoRouter] instance.
final routerProvider = Provider<GoRouter>((ref) {
  return appRouter;
});

/// Application router defining all route configurations and the stateful shell.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.home,
  redirect: authGuardRedirect,
  routes: [
    // Standalone routes without bottom navigation bar
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterAccountScreen(),
    ),
    GoRoute(
      path: AppRoutes.registerFarm,
      builder: (context, state) => const RegisterFarmScreen(),
    ),
    GoRoute(
      path: AppRoutes.diagnoseCapture,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CaptureScreen(),
    ),
    GoRoute(
      path: AppRoutes.diagnoseResult,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ResultScreen(),
    ),
    GoRoute(
      path: AppRoutes.advisor,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AdvisorScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),

    // Stateful shell route for persistent bottom bar tabs
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Planner
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.planner,
              builder: (context, state) => const PlannerScreen(),
            ),
          ],
        ),
        // Tab 2: History
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.history,
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        // Tab 3: Alerts
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.alerts,
              builder: (context, state) => const AlertsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

