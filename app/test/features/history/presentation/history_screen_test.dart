import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/services/connectivity_service.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/offline_banner.dart';
import 'package:app/features/diagnosis/data/fake_diagnosis_repository.dart';
import 'package:app/features/diagnosis/data/providers.dart';
import 'package:app/features/history/data/fake_history_repository.dart';
import 'package:app/features/history/data/providers.dart';
import 'package:app/features/history/presentation/history_screen.dart';
import 'package:app/features/history/presentation/widgets/history_filter_bar.dart';

class MockOfflineNotifier extends ConnectivityNotifier {
  @override
  bool build() => false;
}

class MockOnlineNotifier extends ConnectivityNotifier {
  @override
  bool build() => true;
}

void main() {
  Widget buildHistoryApp({
    bool isOnline = true,
  }) {
    return ProviderScope(
      overrides: [
        connectivityProvider.overrideWith(
          () => isOnline ? MockOnlineNotifier() : MockOfflineNotifier(),
        ),
        historyRepositoryProvider.overrideWithValue(
          FakeHistoryRepository(delay: Duration.zero),
        ),
        diagnosisRepositoryProvider.overrideWithValue(
          FakeDiagnosisRepository(delay: Duration.zero),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HistoryScreen(),
      ),
    );
  }

  group('HistoryScreen', () {
    testWidgets('renders header, filter bar, and both tabs', (tester) async {
      await tester.pumpWidget(buildHistoryApp(isOnline: true));
      await tester.pumpAndSettle();

      expect(find.text('History & Analytics'), findsOneWidget);
      expect(find.text('Diagnoses'), findsOneWidget);
      expect(find.text('Decisions'), findsOneWidget);
      expect(find.byType(HistoryFilterBar), findsOneWidget);
    });

    testWidgets('displays OfflinePill when device is offline', (tester) async {
      await tester.pumpWidget(buildHistoryApp(isOnline: false));
      await tester.pumpAndSettle();

      expect(find.byType(OfflinePill), findsOneWidget);
    });

    testWidgets('renders diagnoses metrics and recent records on Diagnoses tab',
        (tester) async {
      await tester.pumpWidget(buildHistoryApp());
      await tester.pumpAndSettle();

      // Summary metrics
      expect(find.text('Total Scans'), findsOneWidget);
      expect(find.text('Healthy Rate'), findsOneWidget);

      // Section title
      expect(find.textContaining('Recent records'), findsOneWidget);
    });

    testWidgets('switches to Decisions tab and displays decision timeline',
        (tester) async {
      await tester.pumpWidget(buildHistoryApp());
      await tester.pumpAndSettle();

      // Tap the Decisions tab
      await tester.tap(find.text('Decisions'));
      await tester.pumpAndSettle();

      // Verify decisions summary metrics and timeline
      expect(find.text('Decisions'), findsOneWidget);
      expect(find.text('Decision Log'), findsOneWidget);
    });
  });
}

