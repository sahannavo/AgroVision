import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/alerts/data/fake_alerts_repository.dart';
import 'package:app/features/alerts/data/providers.dart';
import 'package:app/features/alerts/presentation/alert_card.dart';
import 'package:app/features/alerts/presentation/alerts_screen.dart';
import 'package:app/features/alerts/presentation/preventive_steps_panel.dart';

void main() {
  group('Integration Flow: Open an Alert', () {
    testWidgets(
        'AlertsScreen renders outbreak alerts, opens preventive steps, and marks alert read on tap',
        (tester) async {
      final fakeAlertsRepo = FakeAlertsRepository(delay: Duration.zero);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            alertsRepositoryProvider.overrideWithValue(fakeAlertsRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const AlertsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(AlertsScreen), findsOneWidget);
      expect(find.byType(AlertCard), findsAtLeastNWidgets(1));
      expect(find.byType(PreventiveStepsPanel), findsOneWidget);

      // Tap the first alert card to mark it read
      final firstAlert = find.byType(AlertCard).first;
      await tester.ensureVisible(firstAlert);
      await tester.pump();
      await tester.tap(firstAlert);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final alerts = await tester.runAsync(() => fakeAlertsRepo.getNearby());
      expect(alerts!.first.isRead, isTrue);
    });
  });
}
