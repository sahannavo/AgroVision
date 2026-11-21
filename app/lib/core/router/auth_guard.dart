import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/providers.dart';
import 'route_names.dart';

/// Routes that do not require the user to be signed in.
const _publicRoutes = {
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.registerFarm,
};

/// Top-level auth redirect guard.
///
/// - Signed-in user hitting a public route (login/register) → redirected to /home.
/// - Signed-out user hitting a protected route → redirected to /login.
/// - All other cases → no redirect (returns null).
///
/// Reads [authStateProvider] through the nearest [ProviderScope] in the widget
/// tree so that [GoRouter] can access Riverpod state without a [Ref].
String? authGuardRedirect(BuildContext context, GoRouterState state) {
  // Read the Riverpod container from the widget tree.
  final container = ProviderScope.containerOf(context, listen: false);
  final authAsync = container.read(authStateProvider);

  // While auth state is still loading (e.g. first frame), do not redirect —
  // the splash screen handles the first navigation.
  if (authAsync.isLoading) return null;

  final isSignedIn = authAsync.valueOrNull != null;
  final isPublic = _publicRoutes.contains(state.matchedLocation);

  if (!isSignedIn && !isPublic) {
    // Protected route accessed without being signed in → go to login.
    return AppRoutes.login;
  }

  if (isSignedIn && isPublic && state.matchedLocation != AppRoutes.splash) {
    // Signed-in user trying to visit login/register → go to home.
    return AppRoutes.home;
  }

  return null; // No redirect needed.
}
