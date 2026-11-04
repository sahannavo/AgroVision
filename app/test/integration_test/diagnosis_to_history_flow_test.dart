import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/diagnosis/data/fake_diagnosis_repository.dart';
import 'package:app/features/diagnosis/data/providers.dart';
import 'package:app/features/diagnosis/domain/diagnosis.dart';
import 'package:app/features/diagnosis/domain/disease_class.dart';
import 'package:app/features/diagnosis/presentation/result_screen.dart';
import 'package:app/features/history/data/fake_history_repository.dart';
import 'package:app/features/history/data/providers.dart';
import 'package:app/features/history/presentation/history_screen.dart';
import 'package:app/features/history/presentation/widgets/record_tile.dart';

void main() {
  group('Integration Flow: Diagnosis to History Journey', () {
    testWidgets('Diagnosis displayed in ResultScreen can be saved and viewed in History',
        (tester) async {
      final fakeDiagRepo = FakeDiagnosisRepository(delay: Duration.zero);
      final fakeHistoryRepo = FakeHistoryRepository(delay: Duration.zero);

      final testDiagnosis = Diagnosis(
        id: 'flow-test-01',
        userId: 'farmer_01',
        cropType: 'Tomato',
        imagePath: '',
        predictedClass: DiseaseClass.earlyBlight,
        confidence: 0.92,
        topMatches: const [
          TopMatch(diseaseClass: DiseaseClass.earlyBlight, confidence: 0.92),
        ],
        diagnosedAt: DateTime.now(),
      );

      // Save diagnosis into repository
      await fakeDiagRepo.save(testDiagnosis);

      // Step 1: Render ResultScreen with test diagnosis
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            diagnosisRepositoryProvider.overrideWithValue(fakeDiagRepo),
            historyRepositoryProvider.overrideWithValue(fakeHistoryRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ResultScreen(diagnosis: testDiagnosis),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.text(DiseaseClass.earlyBlight.displayName), findsWidgets);

      // Step 2: Render HistoryScreen and verify record tile reflects the saved diagnosis
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            diagnosisRepositoryProvider.overrideWithValue(fakeDiagRepo),
            historyRepositoryProvider.overrideWithValue(fakeHistoryRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.byType(RecordTile), findsWidgets);
      expect(find.text(DiseaseClass.earlyBlight.displayName), findsWidgets);
    });
  });
}
