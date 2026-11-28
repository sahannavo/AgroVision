import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:app/core/router/route_names.dart';
import 'package:app/core/services/connectivity_service.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/alerts/data/fake_alerts_repository.dart';
import 'package:app/features/alerts/data/providers.dart';
import 'package:app/features/auth/data/fake_auth_repository.dart';
import 'package:app/features/auth/data/providers.dart';
import 'package:app/features/auth/presentation/register_account_screen.dart';
import 'package:app/features/auth/presentation/register_farm_screen.dart';
import 'package:app/features/crop_plots/data/fake_crop_plot_repository.dart';
import 'package:app/features/crop_plots/data/providers.dart';
import 'package:app/features/diagnosis/data/fake_diagnosis_repository.dart';
import 'package:app/features/diagnosis/data/providers.dart';
import 'package:app/features/home/presentation/home_screen.dart';
import 'package:app/features/weather/data/fake_weather_repository.dart';
import 'package:app/features/weather/data/providers.dart';

class _OnlineConnectivityNotifier extends ConnectivityNotifier {
  @override
  bool build() => true;
}

void main() {
  group('Integration Flow: Register -> Home', () {
    testWidgets('Completing account and farm registration navigates to Home',
        (tester) async {
      final fakeAuthRepo = FakeAuthRepository(
        startSignedIn: false,
        delay: Duration.zero,
      );

      final router = GoRouter(
        initialLocation: AppRoutes.register,
        routes: [
          GoRoute(
            path: AppRoutes.register,
            builder: (context, state) => const RegisterAccountScreen(),
          ),
          GoRoute(
            path: AppRoutes.registerFarm,
            builder: (context, state) => RegisterFarmScreen(
              args: state.extra as AccountRegistrationArgs?,
            ),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepo),
            weatherRepositoryProvider.overrideWithValue(
              FakeWeatherRepository(delay: Duration.zero),
            ),
            cropPlotRepositoryProvider.overrideWithValue(
              FakeCropPlotRepository(delay: Duration.zero),
            ),
            alertsRepositoryProvider.overrideWithValue(
              FakeAlertsRepository(delay: Duration.zero),
            ),
            diagnosisRepositoryProvider.overrideWithValue(
              FakeDiagnosisRepository(delay: Duration.zero),
            ),
            connectivityProvider.overrideWith(_OnlineConnectivityNotifier.new),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(RegisterAccountScreen), findsOneWidget);

      // Step 1: Fill account details
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Saman Silva');
      await tester.enterText(fields.at(1), 'saman.silva@agrovision.lk');
      await tester.enterText(fields.at(2), 'AgroVision123!');
      await tester.enterText(fields.at(3), 'AgroVision123!');

      final termsCheckbox = find.byType(Checkbox);
      await tester.ensureVisible(termsCheckbox);
      await tester.tap(termsCheckbox);
      await tester.pump();

      final continueBtn = find.text('Continue to Step 2: Farm Details');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RegisterFarmScreen), findsOneWidget);

      // Step 2: Complete farm setup
      final finishBtn = find.text('Finish Setup');
      await tester.ensureVisible(finishBtn);
      await tester.tap(finishBtn);
      await tester.pumpAndSettle();

      expect(fakeAuthRepo.currentUser, isNotNull);
      expect(fakeAuthRepo.currentUser!.fullName, 'Saman Silva');
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
