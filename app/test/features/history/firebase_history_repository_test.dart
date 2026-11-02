import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/diagnosis/domain/diagnosis.dart';
import 'package:app/features/diagnosis/domain/diagnosis_repository.dart';
import 'package:app/features/diagnosis/domain/disease_class.dart';
import 'package:app/features/history/data/firebase_history_repository.dart';
import 'package:app/features/history/domain/decision_log_entry.dart';

class MockDiagnosisRepository implements DiagnosisRepository {
  List<Diagnosis> mockHistory = [];

  @override
  Future<List<Diagnosis>> getHistory({String? userId}) async => mockHistory;

  @override
  Stream<List<Diagnosis>> watchHistory({String? userId}) =>
      Stream.value(mockHistory);

  @override
  Future<Diagnosis> save(Diagnosis diagnosis) async {
    mockHistory.add(diagnosis);
    return diagnosis;
  }
}

void main() {
  Diagnosis createTestDiagnosis({
    required String id,
    required DiseaseClass diseaseClass,
    required DateTime diagnosedAt,
    double confidence = 0.9,
    String cropType = 'Tomato',
  }) {
    return Diagnosis(
      id: id,
      userId: 'test_user',
      cropType: cropType,
      imagePath: 'test_path',
      predictedClass: diseaseClass,
      confidence: confidence,
      topMatches: [
        TopMatch(diseaseClass: diseaseClass, confidence: confidence),
      ],
      diagnosedAt: diagnosedAt,
    );
  }

  group('FirebaseHistoryRepository Stats Computation', () {
    test('handles empty diagnoses gracefully', () async {
      final mockDiagRepo = MockDiagnosisRepository();
      mockDiagRepo.mockHistory = [];

      final repo = FirebaseHistoryRepository(
        diagnosisRepository: mockDiagRepo,
      );

      final stats = await repo.getStats();

      expect(stats.totalScans, equals(0));
      expect(stats.healthyPercent, equals(100));
      expect(stats.topIssue, equals('None'));
      expect(stats.diseaseBreakdown.isEmpty, isTrue);
      expect(stats.weeklyScans.length, equals(8));
      expect(stats.weeklyScans.values.every((v) => v == 0), isTrue);
    });

    test('calculates healthy rate, breakdown, and top issue accurately', () async {
      final now = DateTime(2026, 11, 2, 10, 0);
      final diagnoses = [
        createTestDiagnosis(
          id: '1',
          diseaseClass: DiseaseClass.earlyBlight,
          diagnosedAt: now.subtract(const Duration(days: 1)),
        ),
        createTestDiagnosis(
          id: '2',
          diseaseClass: DiseaseClass.earlyBlight,
          diagnosedAt: now.subtract(const Duration(days: 2)),
        ),
        createTestDiagnosis(
          id: '3',
          diseaseClass: DiseaseClass.lateBlight,
          diagnosedAt: now.subtract(const Duration(days: 3)),
        ),
        createTestDiagnosis(
          id: '4',
          diseaseClass: DiseaseClass.healthy,
          diagnosedAt: now.subtract(const Duration(days: 4)),
        ),
      ];

      final stats = FirebaseHistoryRepository.computeStatsFromDiagnoses(
        diagnoses,
        referenceDate: now,
      );

      expect(stats.totalScans, equals(4));
      // 1 healthy out of 4 -> 25%
      expect(stats.healthyPercent, equals(25));
      // Early Blight appears twice vs Late Blight once
      expect(stats.topIssue, equals(DiseaseClass.earlyBlight.displayName));
      expect(stats.diseaseBreakdown[DiseaseClass.earlyBlight.displayName], equals(2));
      expect(stats.diseaseBreakdown[DiseaseClass.lateBlight.displayName], equals(1));
      expect(stats.diseaseBreakdown[DiseaseClass.healthy.displayName], equals(1));

      // Sum of breakdown counts equals total scans
      final breakdownSum =
          stats.diseaseBreakdown.values.fold<int>(0, (sum, val) => sum + val);
      expect(breakdownSum, equals(stats.totalScans));
    });

    test('8-week scan bucketing works across month boundaries', () async {
      // Reference date: 2 Nov 2026 (spanning back across October and September)
      final refDate = DateTime(2026, 11, 2, 12, 0);

      final diagnoses = [
        // W8 (0-7 days ago: Oct 26 - Nov 2)
        createTestDiagnosis(
          id: 'w8_1',
          diseaseClass: DiseaseClass.healthy,
          diagnosedAt: refDate.subtract(const Duration(days: 2)), // Oct 31
        ),
        createTestDiagnosis(
          id: 'w8_2',
          diseaseClass: DiseaseClass.healthy,
          diagnosedAt: refDate.subtract(const Duration(days: 5)), // Oct 28
        ),
        // W7 (7-14 days ago: Oct 19 - Oct 25)
        createTestDiagnosis(
          id: 'w7_1',
          diseaseClass: DiseaseClass.earlyBlight,
          diagnosedAt: refDate.subtract(const Duration(days: 10)), // Oct 23
        ),
        // W1 (49-55 days ago: Sep 8 - Sep 14)
        createTestDiagnosis(
          id: 'w1_1',
          diseaseClass: DiseaseClass.lateBlight,
          diagnosedAt: refDate.subtract(const Duration(days: 50)), // Sep 13
        ),
        // Outside 8-week window (> 56 days ago)
        createTestDiagnosis(
          id: 'old',
          diseaseClass: DiseaseClass.healthy,
          diagnosedAt: refDate.subtract(const Duration(days: 60)),
        ),
      ];

      final stats = FirebaseHistoryRepository.computeStatsFromDiagnoses(
        diagnoses,
        referenceDate: refDate,
      );

      expect(stats.weeklyScans.length, equals(8));
      expect(stats.weeklyScans['W8'], equals(2));
      expect(stats.weeklyScans['W7'], equals(1));
      expect(stats.weeklyScans['W1'], equals(1));
      expect(stats.weeklyScans['W2'], equals(0));
    });
  });

  group('DecisionLogEntry', () {
    test('serialization and properties', () {
      final now = DateTime.now();
      final entry = DecisionLogEntry(
        id: 'dec_123',
        userId: 'farmer_01',
        date: now,
        title: 'Sprayed organic neem oil',
        detail: 'Applied for aphid prevention on eggplant',
        resultLabel: 'Completed',
        syncStatus: SyncStatus.synced,
      );

      expect(entry.id, equals('dec_123'));
      expect(entry.title, contains('neem oil'));
      expect(entry.syncStatus, equals(SyncStatus.synced));
    });
  });
}
