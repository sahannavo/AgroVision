import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_account_screen.dart';
import 'features/auth/presentation/register_farm_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

/// Root application widget for AgroVision.
class AgroVisionApp extends ConsumerWidget {
  const AgroVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _buildRouter(ref);
    return MaterialApp.router(
      title: 'AgroVision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }

  GoRouter _buildRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterAccountScreen(),
        ),
        GoRoute(
          path: '/register/farm',
          builder: (context, state) {
            final args = state.extra;
            return RegisterFarmScreen(args: args is AccountRegistrationArgs ? args : null);
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const _PlaceholderHomeScreen(),
        ),
      ],
    );
  }
}

/// Placeholder home screen — replaced by Task 3 (HomeScreen).
class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AgroVision · Home')),
      body: const Center(child: Text('Home screen — coming in Task 3')),
    );
  }
}
