// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:app/features/auth/data/fake_auth_repository.dart';
import 'package:app/features/auth/data/providers.dart';
import 'package:app/features/auth/presentation/login_screen.dart';
import 'package:app/features/auth/presentation/register_account_screen.dart';
import 'package:app/features/auth/presentation/register_farm_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [child] in the minimal scaffolding needed for GoRouter + Riverpod.
Widget _buildTestApp(
  Widget child, {
  FakeAuthRepository? authRepo,
}) {
  final repo = authRepo ?? FakeAuthRepository(startSignedIn: false);
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => child),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterAccountScreen()),
    GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('Home'))),
    GoRoute(
      path: '/register/farm',
      builder: (context, state) => RegisterFarmScreen(
        args: state.extra is AccountRegistrationArgs
            ? state.extra as AccountRegistrationArgs
            : null,
      ),
    ),
  ]);

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// LoginScreen tests
// ---------------------------------------------------------------------------

void main() {
  group('LoginScreen', () {
    testWidgets('shows "Welcome back" heading', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('shows email and password fields', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows "Log in" button', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('shows validation error when submitting empty form',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Email address is required'), findsOneWidget);
    });

    testWidgets('shows "Create account" link', (tester) async {
      await tester.pumpWidget(_buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Create account'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // RegisterAccountScreen tests
  // -------------------------------------------------------------------------

  group('RegisterAccountScreen', () {
    testWidgets('shows "Create Farmer Account" heading', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const RegisterAccountScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Create Farmer Account'), findsOneWidget);
    });

    testWidgets('shows step progress badge "Step 1 of 2: Account Info"',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const RegisterAccountScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 2: Account Info'), findsOneWidget);
    });

    testWidgets('shows Full Name, Email address fields', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const RegisterAccountScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
    });

    testWidgets('shows "Continue to Step 2: Farm Details" button',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const RegisterAccountScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Continue to Step 2: Farm Details'), findsOneWidget);
    });

    testWidgets('shows validation error for empty name on submit',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const RegisterAccountScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue to Step 2: Farm Details'));
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // RegisterFarmScreen tests
  // -------------------------------------------------------------------------

  group('RegisterFarmScreen', () {
    const sampleArgs = AccountRegistrationArgs(
      fullName: 'Nimal Perera',
      email: 'nimal@test.lk',
      password: 'Password1!',
    );

    testWidgets('shows "Tell us about your farm" heading', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(RegisterFarmScreen(args: sampleArgs)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tell us about your farm'), findsOneWidget);
    });

    testWidgets('shows Farm Location, Soil Type, Total Cultivated Area sections',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(RegisterFarmScreen(args: sampleArgs)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Farm Location'), findsOneWidget);
      expect(find.text('Soil Type'), findsOneWidget);
      expect(find.text('Total Cultivated Area'), findsOneWidget);
    });

    testWidgets('shows crop selection grid with all 4 crops', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(RegisterFarmScreen(args: sampleArgs)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);
      expect(find.text('Chilli'), findsOneWidget);
      expect(find.text('Eggplant'), findsOneWidget);
    });

    testWidgets('shows "Finish Setup" button', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(RegisterFarmScreen(args: sampleArgs)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Finish Setup'), findsOneWidget);
    });
  });
}

