import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrovision/features/alerts/data/fake_alerts_repository.dart';
import 'package:agrovision/features/alerts/domain/alerts_providers.dart';
import 'package:agrovision/features/alerts/domain/alerts_repository.dart';
import 'package:agrovision/features/alerts/domain/outbreak_alert.dart';
import 'package:agrovision/features/alerts/presentation/alerts_screen.dart';

void main() {
  group('AlertsScreen', () {
    late FakeAlertsRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeAlertsRepository();
    });

    Widget buildSubject() {
      return ProviderScope(
        overrides: [
          alertsRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: AlertsScreen(),
        ),
      );
    }

    testWidgets('shows main heading and list view content',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Disease Alerts'), findsOneWidget);
      expect(
        find.text('Surveillance Active · Nightshade Plots'),
        findsOneWidget,
      );
      expect(find.text('Maha Season 2024'), findsOneWidget);
      expect(find.text('Active Outbreak Cluster'), findsOneWidget);
      expect(find.textContaining('Early Blight'), findsWidgets);
      expect(find.textContaining('Bacterial Spot'), findsWidgets);
      expect(
        find.textContaining('Community Crop Protection'),
        findsOneWidget,
      );
    });

    testWidgets('shows toggle between List and Map views',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('List'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
    });

    testWidgets('shows offline banner', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Offline mode'), findsOneWidget);
    });

    testWidgets('first card shows expanded preventive steps',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text('Preventive Steps (Action Required)'),
        findsOneWidget,
      );
      expect(
        find.text('Copper-based prophylactic spray'),
        findsOneWidget,
      );
      expect(find.text('Add to Spray Schedule'), findsOneWidget);
    });

    testWidgets('shows empty state when no alerts',
        (WidgetTester tester) async {
      final emptyRepo = _EmptyAlertsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            alertsRepositoryProvider.overrideWithValue(emptyRepo),
          ],
          child: const MaterialApp(
            home: AlertsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No outbreaks near you'), findsOneWidget);
    });
  });
}

/// Repository that returns an empty alerts list for testing empty state.
class _EmptyAlertsRepository implements AlertsRepository {
  @override
  Stream<AlertsData> watchNearby() {
    return Stream.value(
      AlertsData(
        seasonSummary: const SeasonSummary(
          seasonName: 'Maha Season 2024',
          riskLabel: 'Low Risk',
          district: 'Kurunegala District',
          weatherInfo: '60% Humidity',
          activeZoneCount: 0,
          radiusKm: 20,
        ),
        alerts: const [],
        userPlot: const UserPlotLocation(
          plotName: 'Test Plot',
          latitude: 7.49,
          longitude: 80.38,
        ),
        lastUpdated: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> markRead(String alertId) async {}
}
