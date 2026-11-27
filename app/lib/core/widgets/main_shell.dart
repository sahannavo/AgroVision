import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/notification_service.dart';
import '../../features/auth/data/providers.dart';
import 'app_bottom_nav.dart';

/// Shell widget providing persistent bottom navigation for root tabs
/// and in-app foreground outbreak notification handling.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    // Register foreground push notification listener to show in-app banner
    NotificationService().setForegroundAlertHandler(
      ({required String title, required String body, required String alertId}) {
        if (!mounted) return;
        NotificationService().showInAppBanner(
          context,
          title: title,
          body: body,
          onTap: () {
            // Tab 3 is Alerts
            widget.navigationShell.goBranch(3);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep notification service in sync with current authenticated user
    final authUser = ref.watch(authStateProvider).valueOrNull;
    if (authUser != null && !NotificationService().isInitialized) {
      NotificationService().initialize(userId: authUser.uid);
    } else if (authUser == null && NotificationService().isInitialized) {
      NotificationService().reset();
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
