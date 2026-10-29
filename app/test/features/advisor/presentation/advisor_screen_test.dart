import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/advisor/data/fake_advisor_repository.dart';
import 'package:app/features/advisor/data/providers.dart';
import 'package:app/features/advisor/domain/advisor_repository.dart';
import 'package:app/features/advisor/domain/planting_recommendation.dart';
import 'package:app/features/advisor/presentation/advisor_screen.dart';
import 'package:app/features/weather/data/providers.dart';
import 'package:app/features/weather/domain/weather_forecast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A cached weather forecast stamped 3 hours ago — drives the banner text.
WeatherForecast _cachedForecast3hAgo() {
  final fetchedAt = DateTime.now().subtract(const Duration(hours: 3));
  return WeatherForecast(
    currentTemperature: 29.0,
    condition: 'Scattered Clouds',
    humidity: 89,
    rainChance: 40,
    daily: const [],
    fetchedAt: fetchedAt,
    isCached: true,
  );
}

/// A fresh (non-cached) forecast — banner should not appear.
WeatherForecast _freshForecast() {
  return WeatherForecast(
    currentTemperature: 29.0,
    condition: 'Scattered Clouds',
    humidity: 89,
    rainChance: 40,
    daily: const [],
    fetchedAt: DateTime.now(),
    isCached: false,
  );
}

Widget _wrapWithScope({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light,
      home: child,
    ),
  );
}

class _FailingAdvisorRepository implements AdvisorRepository {
  @override
  Future<List<PlantingRecommendation>> recommend({
    required String soil,
    required String season,
    String? location,
  }) async {
    throw Exception('Simulated network failure');
  }
}

void main() {
  group('AdvisorScreen Widget Tests', () {
    testWidgets('renders initial screen with input card and empty state', (tester) async {
      await tester.pumpWidget(
        _wrapWithScope(
          overrides: [
            // Provide a known cached forecast so the banner shows predictably.
            weatherForecastProvider.overrideWith((_) async => _cachedForecast3hAgo()),
          ],
          child: const AdvisorScreen(),
        ),
      );

      // Settle so the FutureProvider resolves.
      await tester.pumpAndSettle();

      // Verify App Bar
      expect(find.text('Planting Advisor'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Verify Input Card
      expect(find.text('Field location'), findsOneWidget);
      expect(find.text('Kurunegala, NW'), findsOneWidget);
      expect(find.text('Detect'), findsOneWidget);
      expect(find.text('Soil type'), findsOneWidget);
      expect(find.text('Loam'), findsOneWidget);
      expect(find.text('Cultivation season'), findsOneWidget);
      // Banner: forecast is cached 3 hrs ago → "3 hrs ago"
      expect(find.text('Using weather saved 3 hrs ago'), findsOneWidget);
      expect(find.text('Get recommendations'), findsOneWidget);

      // Verify Empty State before search
      expect(find.text('Find what grows best on your land'), findsOneWidget);
      expect(find.text('Choose your soil, season and location to see ranked nightshade crops.'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Chilli'), findsOneWidget);
      expect(find.text('Eggplant'), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);
    });

    testWidgets('triggers recommendation search and displays ranked results', (tester) async {
      final fakeRepo = FakeAdvisorRepository(delay: Duration.zero);

      await tester.pumpWidget(
        _wrapWithScope(
          overrides: [
            advisorRepositoryProvider.overrideWithValue(fakeRepo),
            // Use a fresh (non-cached) forecast — banner hidden.
            weatherForecastProvider.overrideWith((_) async => _freshForecast()),
          ],
          child: const AdvisorScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Get recommendations"
      await tester.tap(find.text('Get recommendations'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Results header should now be present
      expect(find.text('Best crops for you'), findsOneWidget);
      expect(find.textContaining('nightshade crops analyzed'), findsOneWidget);

      // Verify crop cards rendered
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('#1 Choice'), findsOneWidget);
      expect(find.text('94%'), findsOneWidget);
      expect(find.text('Match'), findsWidgets);

      expect(find.text('Chilli'), findsOneWidget);
      expect(find.text('88%'), findsOneWidget);

      expect(find.text('Eggplant'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);

      expect(find.text('Potato'), findsOneWidget);
      expect(find.text('62%'), findsOneWidget);
      expect(find.text('Caution'), findsOneWidget);
      expect(find.textContaining('Too warm'), findsOneWidget);
    });

    testWidgets('shows error card with retry when repository throws error', (tester) async {
      await tester.pumpWidget(
        _wrapWithScope(
          overrides: [
            advisorRepositoryProvider.overrideWithValue(_FailingAdvisorRepository()),
            weatherForecastProvider.overrideWith((_) async => _freshForecast()),
          ],
          child: const AdvisorScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Get recommendations
      await tester.tap(find.text('Get recommendations'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Error card displayed
      expect(find.text('Recommendation Error'), findsOneWidget);
      expect(find.text('Retry Analysis'), findsOneWidget);
    });

    testWidgets('detect location updates location and shows snackbar', (tester) async {
      await tester.pumpWidget(
        _wrapWithScope(
          overrides: [
            weatherForecastProvider.overrideWith((_) async => _freshForecast()),
          ],
          child: const AdvisorScreen(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Detect'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Field location detected'), findsOneWidget);
    });
  });
}
