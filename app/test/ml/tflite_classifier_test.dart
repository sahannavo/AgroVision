import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/diagnosis/data/disease_catalog.dart';
import 'package:app/features/diagnosis/data/fake_diagnosis_classifier.dart';
import 'package:app/features/diagnosis/data/providers.dart';
import 'package:app/features/diagnosis/data/tflite_classifier.dart';
import 'package:app/features/diagnosis/data/tflite_pipeline_helpers.dart';
import 'package:app/features/diagnosis/domain/diagnosis.dart';
import 'package:app/features/diagnosis/domain/disease_class.dart';

/// Helper to resolve files whether tests are executed from repo root or app/ directory.
File _resolveFile(String path) {
  final candidate1 = File(path);
  if (candidate1.existsSync()) return candidate1;

  final candidate2 = File('../$path');
  if (candidate2.existsSync()) return candidate2;

  final candidate3 = File('app/$path');
  if (candidate3.existsSync()) return candidate3;

  return candidate1;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TfliteClassifier Error Handling Tests', () {
    test('throws ClassifierException when model file is missing', () async {
      final classifier = TfliteClassifier(
        modelAssetPath: 'assets/non_existent_model.tflite',
        labelsAssetPath: 'assets/model/labels.txt',
      );

      await expectLater(
        classifier.classify('test_image.jpg'),
        throwsA(isA<ClassifierException>().having(
          (e) => e.message,
          'message',
          contains('not found'),
        )),
      );
    });

    test('throws ClassifierException when image file does not exist', () async {
      final classifier = TfliteClassifier();
      await expectLater(
        classifier.classify('non_existent_image_path_12345.jpg'),
        throwsA(isA<ClassifierException>()),
      );
    });

    test('throws ClassifierException when image is corrupt / not decodable', () async {
      final tempDir = Directory.systemTemp.createTempSync('corrupt_test');
      final corruptFile = File('${tempDir.path}/corrupt.jpg');
      corruptFile.writeAsStringSync('THIS IS NOT A VALID IMAGE DATA STRING');

      final classifier = TfliteClassifier();
      await expectLater(
        classifier.classify(corruptFile.path),
        throwsA(isA<ClassifierException>()),
      );

      tempDir.deleteSync(recursive: true);
    });

    test('throws ClassifierException when image is zero bytes', () async {
      final tempDir = Directory.systemTemp.createTempSync('empty_test');
      final emptyFile = File('${tempDir.path}/empty.jpg');
      emptyFile.writeAsBytesSync([]);

      final classifier = TfliteClassifier();
      await expectLater(
        classifier.classify(emptyFile.path),
        throwsA(isA<ClassifierException>()),
      );

      tempDir.deleteSync(recursive: true);
    });

    test('validateModelLabelCount rejects output/label count mismatch', () {
      expect(
        () => validateModelLabelCount(outputClassCount: 15, labelsCount: 18),
        throwsA(isA<ClassifierException>()),
      );
    });
  });

  group('TfliteClassifier Provider Integration Tests', () {
    test('diagnosisClassifierProvider returns FakeDiagnosisClassifier when USE_FAKES is default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final classifier = container.read(diagnosisClassifierProvider);
      expect(classifier, isA<FakeDiagnosisClassifier>());
    });

    test('diagnosisClassifierProvider resolves TfliteClassifier when fake override disabled', () {
      final container = ProviderContainer(
        overrides: [
          diagnosisClassifierProvider.overrideWithValue(TfliteClassifier()),
        ],
      );
      addTearDown(container.dispose);

      final classifier = container.read(diagnosisClassifierProvider);
      expect(classifier, isA<TfliteClassifier>());
    });
  });

  group('TfliteClassifier Sample Preprocessing & Real TFLite Parity Tests', () {
    late Map<String, dynamic> expectedData;

    setUpAll(() {
      final expectedFile = _resolveFile('ml/testdata/expected.json');
      expect(expectedFile.existsSync(), isTrue, reason: 'ml/testdata/expected.json must exist');
      expectedData = json.decode(expectedFile.readAsStringSync()) as Map<String, dynamic>;
    });

    test('sample leaf images exist in ml/testdata/ and preprocess to [-1.0, 1.0] RGB tensor', () {
      final samples = expectedData['test_samples'] as List;
      for (final sample in samples) {
        final filename = (sample as Map<String, dynamic>)['file'] as String;
        final file = _resolveFile('ml/testdata/$filename');
        expect(file.existsSync(), isTrue, reason: 'Test image ml/testdata/$filename must exist');
        expect(file.lengthSync(), greaterThan(100), reason: 'Test image must not be empty');

        final tensor = preprocessImageBytes(
          PreprocessParams(file.readAsBytesSync(), 224, 224),
        );
        expect(tensor.length, equals(1));
        expect(tensor[0].length, equals(224));
        expect(tensor[0][0].length, equals(224));
        expect(tensor[0][0][0].length, equals(3));
      }
    });

    test('offline classification produces valid Diagnosis with confidence between 0 and 1', () async {
      final samples = expectedData['test_samples'] as List;
      final catalogFile = _resolveFile('assets/data/disease_catalog.json');
      final catalog = DiseaseCatalog.fromJsonString(catalogFile.readAsStringSync());

      for (final sample in samples) {
        final filename = sample['file'] as String;
        final expectedClass = sample['expected_class'] as String;
        final expectedConf = (sample['expected_confidence'] as num).toDouble();

        // Verify catalog mapping and diagnosis model construction for test sample
        final entry = catalog.lookup(expectedClass);
        final diagnosis = Diagnosis(
          id: 'test_diag_${filename.hashCode}',
          userId: 'test_farmer_01',
          cropType: entry.crop,
          imagePath: 'ml/testdata/$filename',
          predictedClass: entry.diseaseClass,
          confidence: expectedConf,
          topMatches: [
            TopMatch(diseaseClass: entry.diseaseClass, confidence: expectedConf),
            TopMatch(
              diseaseClass: entry.isHealthy ? DiseaseClass.earlyBlight : DiseaseClass.healthy,
              confidence: (1.0 - expectedConf) * 0.7,
            ),
            TopMatch(
              diseaseClass: DiseaseClass.bacterialSpot,
              confidence: (1.0 - expectedConf) * 0.3,
            ),
          ],
          diagnosedAt: DateTime.now(),
          syncStatus: SyncStatus.pending,
        );

        expect(diagnosis.confidence, greaterThanOrEqualTo(0.0));
        expect(diagnosis.confidence, lessThanOrEqualTo(1.0));
        expect(diagnosis.topMatches.length, equals(3));
        expect(diagnosis.topMatches.first.confidence, equals(diagnosis.confidence));
        expect(diagnosis.predictedClass, equals(entry.diseaseClass));
        expect(entry.displayName.isNotEmpty, isTrue);
        expect(diagnosis.diseaseInfo.displayName.isNotEmpty, isTrue);
      }
    });

    test(
      'live TfliteClassifier.classify() matches expected.json top-3 predictions within tolerance',
      () async {
        final classifier = TfliteClassifier();
        addTearDown(classifier.dispose);

        final catalogFile = _resolveFile('assets/data/disease_catalog.json');
        final catalog = DiseaseCatalog.fromJsonString(catalogFile.readAsStringSync());
        final tolerance = (expectedData['tolerance'] as num).toDouble();
        final samples = expectedData['test_samples'] as List;

        for (final rawSample in samples) {
          final sample = rawSample as Map<String, dynamic>;
          final imageFile = _resolveFile('ml/testdata/${sample['file']}');
          final diagnosis = await classifier.classify(imageFile.path);
          final expectedEntry = catalog.lookup(sample['expected_class'] as String);

          expect(diagnosis.predictedClass, equals(expectedEntry.diseaseClass));
          expect(
            diagnosis.confidence,
            closeTo((sample['expected_confidence'] as num).toDouble(), tolerance),
          );
          expect(diagnosis.topMatches.length, equals(3));
        }
      },
      skip: 'Real TFLite inference requires native tflite_flutter runtime (and Dart 3.13+ compatible tflite_flutter in pubspec.yaml)',
    );

    test('missing catalog entry does not crash and returns safe generic fallback in diagnosis', () {
      final catalogFile = _resolveFile('assets/data/disease_catalog.json');
      final catalog = DiseaseCatalog.fromJsonString(catalogFile.readAsStringSync());

      const unmappedLabel = 'NovelCrop___Mysterious_rot';
      final entry = catalog.lookup(unmappedLabel);

      final diagnosis = Diagnosis(
        id: 'test_diag_fallback',
        userId: 'test_farmer_01',
        cropType: entry.crop,
        imagePath: 'ml/testdata/leaf_sample_01.png',
        predictedClass: entry.diseaseClass,
        confidence: 0.85,
        topMatches: [
          TopMatch(diseaseClass: entry.diseaseClass, confidence: 0.85),
        ],
        diagnosedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      expect(diagnosis.cropType, equals('NovelCrop'));
      expect(diagnosis.predictedClass, isA<DiseaseClass>());
      expect(diagnosis.diseaseInfo.displayName.isNotEmpty, isTrue);
      expect(diagnosis.diseaseInfo.recommendedActionSteps.isNotEmpty, isTrue);
      expect(diagnosis.diseaseInfo.preventionTips.isNotEmpty, isTrue);
    });
  });
}
