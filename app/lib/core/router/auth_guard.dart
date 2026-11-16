import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Top-level auth redirect guard.
/// During Phase 2 UI development, returns null to allow unrestricted UI testing.
String? authGuardRedirect(BuildContext context, GoRouterState state) {
  return null;
}
