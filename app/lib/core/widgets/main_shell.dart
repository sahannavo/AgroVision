import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/route_names.dart';
import 'app_bottom_nav.dart';

/// Main application shell holding the persistent [AppBottomNav].
///
/// Wraps [StatefulNavigationShell] from go_router so the 4 primary tabs
/// (Home, Planner, History, Alerts) maintain their state across tab switches.
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  /// The stateful navigation shell passed by [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _onScanPressed(BuildContext context) {
    context.push(AppRoutes.diagnoseCapture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTabSelected: _onTabSelected,
        onScanPressed: () => _onScanPressed(context),
      ),
    );
  }
}

