import 'package:app/features/diagnosis/data/fake_diagnosis_classifier.dart';
import 'package:app/features/diagnosis/data/fake_diagnosis_repository.dart';
import 'package:app/features/diagnosis/domain/diagnosis.dart';
import 'package:app/features/diagnosis/domain/disease_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeDiagnosisClassifier', () {
    test('classifies image as Early Blight at 92% confidence', () async {
      final classifier = FakeDiagnosisClassifier(delay: Duration.zero);
      final diagnosis = await classifier.classify('test/leaf.jpg', cropType: 'Tomato');

      expect(diagnosis.predictedClass, equals(DiseaseClass.earlyBlight));
      expect(diagnosis.confidence, equals(0.92));
      expect(diagnosis.topMatches.length, equals(3));
      expect(diagnosis.topMatches.first.diseaseClass, equals(DiseaseClass.earlyBlight));
      expect(diagnosis.topMatches.first.confidence, equals(0.92));
      expect(diagnosis.diseaseInfo.displayName, equals('Early Blight'));
      expect(diagnosis.diseaseInfo.scientificName, equals('Alternaria solani'));
      expect(diagnosis.diseaseInfo.recommendedActionSteps, isNotEmpty);
      expect(diagnosis.diseaseInfo.preventionTips, isNotEmpty);
    });
  });

  group('FakeDiagnosisRepository', () {
    late FakeDiagnosisRepository repo;

    setUp(() {
      repo = FakeDiagnosisRepository(delay: Duration.zero);
    });

    tearDown(() {
      repo.dispose();
    });

    test('initializes with sample history records', () async {
      final history = await repo.getHistory();
      expect(history.length, equals(3));
      expect(history.first.predictedClass, equals(DiseaseClass.earlyBlight));
      expect(history.first.confidence, equals(0.92));
      expect(history.first.syncStatus, equals(SyncStatus.synced));
    });

    test('save adds diagnosis to top of history list', () async {
      final newDiag = Diagnosis(
        id: 'diag_test_99',
        userId: 'farmer_nimal_01',
        cropType: 'Chilli',
        imagePath: 'test/path.jpg',
        predictedClass: DiseaseClass.leafCurl,
        confidence: 0.88,
        topMatches: const [
          TopMatch(diseaseClass: DiseaseClass.leafCurl, confidence: 0.88),
        ],
        diagnosedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      await repo.save(newDiag);
      final history = await repo.getHistory();
      expect(history.first.id, equals('diag_test_99'));
      expect(history.first.syncStatus, equals(SyncStatus.pending));
    });
  });
}
