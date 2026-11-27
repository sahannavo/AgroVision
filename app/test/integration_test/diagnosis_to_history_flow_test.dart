import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/services/connectivity_service.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/diagnosis/data/fake_diagnosis_classifier.dart';
import 'package:app/features/diagnosis/data/fake_diagnosis_repository.dart';
import 'package:app/features/diagnosis/data/providers.dart';
import 'package:app/features/diagnosis/domain/disease_class.dart';
import 'package:app/features/diagnosis/presentation/result_screen.dart';
import 'package:app/features/history/data/fake_history_repository.dart';
import 'package:app/features/history/data/providers.dart';
import 'package:app/features/history/presentation/history_screen.dart';
import 'package:app/features/history/presentation/widgets/record_tile.dart';

class _OnlineConnectivityNotifier extends ConnectivityNotifier {
  @override
  bool build() => true;
}

void main() {
  group('Integration Flow: Scan -> Result -> Save -> History', () {
    testWidgets(
        'Classifier output in ResultScreen saves to repository and appears in History',
        (tester) async {
      final fakeClassifier = FakeDiagnosisClassifier(delay: Duration.zero);
      final fakeDiagRepo = FakeDiagnosisRepository(delay: Duration.zero);
      final fakeHistoryRepo = FakeHistoryRepository(delay: Duration.zero);

      // Step 1: Run on-device classifier (fake) as CaptureScreen does
      final scannedDiagnosis = (await tester.runAsync(
        () => fakeClassifier.classify(
          'assets/images/placeholder_logo.png',
          cropType: 'Tomato',
        ),
      ))!;

      // Step 2: Render ResultScreen and tap "Save to history"
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            diagnosisRepositoryProvider.overrideWithValue(fakeDiagRepo),
            historyRepositoryProvider.overrideWithValue(fakeHistoryRepo),
            connectivityProvider.overrideWith(_OnlineConnectivityNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ResultScreen(diagnosis: scannedDiagnosis),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.text(DiseaseClass.earlyBlight.displayName), findsWidgets);

      final saveButton = find.text('Save to history');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Saved to history'), findsWidgets);
      final savedList =
          (await tester.runAsync(() => fakeDiagRepo.getHistory()))!;
      expect(savedList.any((d) => d.id == scannedDiagnosis.id), isTrue);

      // Step 3: Render HistoryScreen and verify RecordTile reflects the saved diagnosis
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            diagnosisRepositoryProvider.overrideWithValue(fakeDiagRepo),
            historyRepositoryProvider.overrideWithValue(fakeHistoryRepo),
            connectivityProvider.overrideWith(_OnlineConnectivityNotifier.new),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HistoryScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.byType(RecordTile), findsWidgets);
      expect(find.text(DiseaseClass.earlyBlight.displayName), findsWidgets);
    });
  });
}
