import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// Navigation guard for authentication redirects.
///
/// Sends unauthenticated users to [AppRoutes.login] once auth state
/// management is connected from the contracts task. Until then, allows
/// access to all routes to facilitate independent development and testing.
String? authGuardRedirect(BuildContext context, GoRouterState state) {
  // Note: Connect authStateProvider when merged from the contracts task:
  // final user = ref.read(authStateProvider).value;
  // final isAuthRoute = state.matchedLocation == AppRoutes.login ||
  //     state.matchedLocation == AppRoutes.register ||
  //     state.matchedLocation == AppRoutes.registerFarm ||
  //     state.matchedLocation == AppRoutes.splash;
  // if (user == null && !isAuthRoute) return AppRoutes.login;
  // if (user != null && isAuthRoute) return AppRoutes.home;
  return null;
}

