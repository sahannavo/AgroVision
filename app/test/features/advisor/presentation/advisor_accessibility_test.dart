import 'package:app/features/advisor/data/fake_advisor_repository.dart';
import 'package:app/features/advisor/data/providers.dart';
import 'package:app/features/advisor/presentation/advisor_screen.dart';
import 'package:app/features/weather/data/providers.dart';
import 'package:app/features/weather/domain/weather_forecast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

WeatherForecast _sampleWeather() {
  return WeatherForecast(
    currentTemperature: 28.5,
    condition: 'Partly Cloudy',
    humidity: 80,
    rainChance: 35,
    daily: const [],
    fetchedAt: DateTime.now().subtract(const Duration(hours: 2)),
    isCached: true,
  );
}

Widget _wrapScreen(Widget child, {double textScale = 1.0, Size size = const Size(360, 800)}) {
  return ProviderScope(
    overrides: [
      advisorRepositoryProvider.overrideWithValue(FakeAdvisorRepository(delay: Duration.zero)),
      weatherForecastProvider.overrideWith((_) async => _sampleWeather()),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child,
      ),
    ),
  );
}

void main() {
  group('Phase 5 QA & Accessibility Audit: AdvisorScreen & Components', () {
    testWidgets('AdvisorScreen renders with zero overflow on narrow screen (360dp width)', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrapScreen(const AdvisorScreen(), size: const Size(360, 800)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Planting Advisor'), findsOneWidget);
    });

    testWidgets('AdvisorScreen renders with zero overflow on wide screen (430dp width)', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrapScreen(const AdvisorScreen(), size: const Size(430, 932)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Planting Advisor'), findsOneWidget);
    });

    testWidgets('AdvisorScreen supports 130% accessibility text scaling without overflow', (tester) async {
      tester.view.physicalSize = const Size(380, 840);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _wrapScreen(
          const AdvisorScreen(),
          textScale: 1.3,
          size: const Size(380, 840),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Planting Advisor'), findsOneWidget);
    });

    testWidgets('Tap targets meet or exceed 48x48 dp accessibility minimum', (tester) async {
      await tester.pumpWidget(_wrapScreen(const AdvisorScreen()));
      await tester.pumpAndSettle();

      // Back navigation button tap target (IconButton)
      final backButton = find.byType(IconButton);
      expect(backButton, findsOneWidget);
      final backSize = tester.getSize(backButton);
      expect(backSize.width, greaterThanOrEqualTo(48.0 - 0.1));
      expect(backSize.height, greaterThanOrEqualTo(48.0 - 0.1));

      // Recommendation submission button
      final submitButton = find.widgetWithText(ElevatedButton, 'Get recommendations');
      expect(submitButton, findsOneWidget);
      final submitSize = tester.getSize(submitButton);
      expect(submitSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Semantics and screen reader labels are present on interactive elements', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrapScreen(const AdvisorScreen()));
      await tester.pumpAndSettle();

      // Check back button semantics
      expect(
        find.bySemanticsLabel('Navigate back'),
        findsOneWidget,
      );

      // Check detect location button semantics
      expect(
        find.bySemanticsLabel('Detect current location'),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('AdvisorScreen search result display retains complete accessibility at 130% text scale', (tester) async {
      await tester.pumpWidget(
        _wrapScreen(
          const AdvisorScreen(),
          textScale: 1.3,
          size: const Size(390, 844),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get recommendations'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Best crops for you'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('#1 Choice'), findsOneWidget);
    });
  });
}
