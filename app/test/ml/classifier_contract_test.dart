import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:app/features/diagnosis/data/disease_catalog.dart';
import 'package:app/features/diagnosis/data/tflite_pipeline_helpers.dart';
import 'package:app/features/diagnosis/domain/diagnosis.dart';
import 'package:app/features/diagnosis/domain/disease_class.dart';

/// Pure-Dart contract tests for the TFLite classifier pipeline helpers:
/// - Preprocessing contract (224x224, RGB order, [-1.0, 1.0] scaling, EXIF baking)
/// - Output tensor vs labels.txt count validation
/// - Softmax / probability normalization and top-3 ranking
/// - Canonical label-to-catalog mapping for all 18 Model v2 classes
///
/// NOTE: These tests run purely in Dart without loading `tflite_flutter` or
/// executing real TensorFlow Lite model inference. Real TFLite model parity
/// must be executed on-device or with a working TFLite runtime.
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
  group('Pure-Dart Preprocessing Contract Tests', () {
    test('preprocessImageBytes produces [1, 224, 224, 3] float values in [-1.0, 1.0] for ml/testdata samples', () {
      final expectedFile = _resolveFile('ml/testdata/expected.json');
      expect(expectedFile.existsSync(), isTrue);

      final expected = json.decode(expectedFile.readAsStringSync()) as Map<String, dynamic>;
      final spec = expected['preprocessing_spec'] as Map<String, dynamic>;
      final dims = (spec['input_dimension'] as List).cast<int>();
      expect(dims, equals([224, 224, 3]));
      expect(spec['color_order'], equals('RGB'));

      final samples = expected['test_samples'] as List;
      for (final sample in samples) {
        final filename = (sample as Map<String, dynamic>)['file'] as String;
        final imageFile = _resolveFile('ml/testdata/$filename');
        expect(imageFile.existsSync(), isTrue, reason: 'Missing ml/testdata/$filename');

        final tensor = preprocessImageBytes(
          PreprocessParams(imageFile.readAsBytesSync(), dims[0], dims[1]),
        );

        expect(tensor.length, equals(1));
        expect(tensor[0].length, equals(224));
        expect(tensor[0][0].length, equals(224));
        expect(tensor[0][0][0].length, equals(3));

        for (final row in tensor[0]) {
          for (final pixel in row) {
            for (final channel in pixel) {
              expect(channel.isFinite, isTrue);
              expect(channel, greaterThanOrEqualTo(-1.0));
              expect(channel, lessThanOrEqualTo(1.0));
            }
          }
        }
      }
    });

    test('preprocessImageBytes preserves RGB order and (pixel - 127.5) / 127.5 scaling', () {
      // Solid pure-red image: R=255, G=0, B=0 -> [1.0, -1.0, -1.0]
      final redImage = img.Image(width: 16, height: 16);
      img.fill(redImage, color: img.ColorRgb8(255, 0, 0));
      final pngBytes = Uint8List.fromList(img.encodePng(redImage));

      final tensor = preprocessImageBytes(PreprocessParams(pngBytes, 224, 224));
      final pixel = tensor[0][112][112];

      expect(pixel[0], closeTo(1.0, 1e-6));
      expect(pixel[1], closeTo(-1.0, 1e-6));
      expect(pixel[2], closeTo(-1.0, 1e-6));
    });

    test('preprocessImageBytes bakes EXIF orientation before resizing', () {
      // Create a 4x2 landscape image: top-left pixel is green, rest are black,
      // and tag it with EXIF orientation 6 (90° CW -> becomes 2x4 portrait,
      // green pixel moves from top-left (0,0) to top-right).
      final base = img.Image(width: 4, height: 2);
      img.fill(base, color: img.ColorRgb8(0, 0, 0));
      base.setPixelRgb(0, 0, 0, 255, 0);
      base.exif.imageIfd.orientation = 6;
      final jpgBytes = Uint8List.fromList(img.encodeJpg(base, quality: 100));

      final tensor = preprocessImageBytes(PreprocessParams(jpgBytes, 4, 4));
      final topRight = tensor[0][0][3];
      final bottomLeft = tensor[0][3][0];

      // Green channel at top-right should be positive after 90° CW bake, while bottom-left stays near -1.0
      expect(topRight[1], greaterThan(0.5));
      expect(bottomLeft[1], lessThan(-0.5));
    });

    test('preprocessImageBytes throws ClassifierException on invalid/empty bytes', () {
      expect(
        () => preprocessImageBytes(PreprocessParams(Uint8List(0), 224, 224)),
        throwsA(isA<ClassifierException>()),
      );
      expect(
        () => preprocessImageBytes(
          PreprocessParams(Uint8List.fromList('not-an-image'.codeUnits), 224, 224),
        ),
        throwsA(isA<ClassifierException>()),
      );
    });
  });

  group('Pure-Dart Output Validation, Softmax & Top-3 Ranking Tests', () {
    late List<String> labels;
    late DiseaseCatalog catalog;

    setUpAll(() {
      final labelsFile = _resolveFile('assets/model/labels.txt');
      labels = labelsFile
          .readAsStringSync()
          .split(RegExp(r'\r?\n'))
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      final catalogFile = _resolveFile('assets/data/disease_catalog.json');
      catalog = DiseaseCatalog.fromJsonString(catalogFile.readAsStringSync());
    });

    test('validateModelLabelCount passes for 18-class match and throws on v1/v2 mismatch', () {
      expect(
        () => validateModelLabelCount(outputClassCount: 18, labelsCount: labels.length),
        returnsNormally,
      );
      expect(
        () => validateModelLabelCount(outputClassCount: 15, labelsCount: 18),
        throwsA(isA<ClassifierException>().having(
          (e) => e.message,
          'message',
          allOf(contains('15'), contains('18')),
        )),
      );
      expect(
        () => validateModelLabelCount(outputClassCount: 0, labelsCount: 18),
        throwsA(isA<ClassifierException>()),
      );
    });

    test('normalizeModelProbabilities preserves valid probabilities and applies softmax to raw logits', () {
      final probs = normalizeModelProbabilities([0.80, 0.15, 0.05]);
      expect(probs, equals([0.80, 0.15, 0.05]));

      // Raw logits summing to ~1.0 with negative values must still get softmaxed
      final fromLogits = normalizeModelProbabilities([3.0, -1.0, -1.0]);
      final sum = fromLogits.reduce((a, b) => a + b);
      expect(sum, closeTo(1.0, 1e-6));
      expect(fromLogits[0], greaterThan(0.9));
      expect(fromLogits[1], greaterThan(0.0));
    });

    test('rankPredictions and buildDiagnosisFromScores handle all 3 new Model v2 classes', () {
      final v2Cases = <({
        int index,
        String label,
        DiseaseClass expectedClass,
        String expectedCrop,
      })>[
        (
          index: 15,
          label: 'Chilli___Leaf_curl',
          expectedClass: DiseaseClass.leafCurl,
          expectedCrop: 'Chilli',
        ),
        (
          index: 16,
          label: 'Eggplant___healthy',
          expectedClass: DiseaseClass.healthy,
          expectedCrop: 'Eggplant',
        ),
        (
          index: 17,
          label: 'General___Nitrogen_deficiency',
          expectedClass: DiseaseClass.nitrogenDeficiency,
          expectedCrop: 'Nightshade Crops',
        ),
      ];

      for (final testCase in v2Cases) {
        expect(labels[testCase.index], equals(testCase.label));
        final scores = List<double>.filled(labels.length, 0.005);
        scores[testCase.index] = 0.85;
        scores[0] = 0.06; // Tomato___Early_blight as runner-up

        final diagnosis = buildDiagnosisFromScores(
          labels: labels,
          rawOutputs: scores,
          catalog: catalog,
          imagePath: 'ml/testdata/leaf_sample_01.png',
        );

        expect(diagnosis.predictedClass, equals(testCase.expectedClass));
        expect(diagnosis.cropType, equals(testCase.expectedCrop));
        expect(diagnosis.confidence, closeTo(0.85, 1e-6));
        expect(diagnosis.topMatches.length, equals(3));
        expect(diagnosis.topMatches.first.diseaseClass, equals(testCase.expectedClass));
        expect(diagnosis.topMatches[0].confidence, greaterThanOrEqualTo(diagnosis.topMatches[1].confidence));
        expect(diagnosis.topMatches[1].confidence, greaterThanOrEqualTo(diagnosis.topMatches[2].confidence));
        expect(diagnosis.syncStatus, equals(SyncStatus.pending));
      }
    });

    test('simulated score vectors matching expected.json rank top-3 classes accurately (not real TFLite inference)', () {
      final expectedFile = _resolveFile('ml/testdata/expected.json');
      final expected = json.decode(expectedFile.readAsStringSync()) as Map<String, dynamic>;
      final samples = expected['test_samples'] as List;

      for (final rawSample in samples) {
        final sample = rawSample as Map<String, dynamic>;
        final top3Expected = (sample['top_3_predictions'] as List).cast<Map<String, dynamic>>();

        // Construct simulated 18-class output matching expected.json top-3 probabilities
        final scores = List<double>.filled(labels.length, 0.001);
        for (final pred in top3Expected) {
          final idx = labels.indexOf(pred['label'] as String);
          expect(idx, isNonNegative);
          scores[idx] = (pred['probability'] as num).toDouble();
        }

        final diagnosis = buildDiagnosisFromScores(
          labels: labels,
          rawOutputs: scores,
          catalog: catalog,
          imagePath: 'ml/testdata/${sample['file']}',
        );

        final expectedTop1 = catalog.lookup(sample['expected_class'] as String);
        expect(diagnosis.predictedClass, equals(expectedTop1.diseaseClass));
        expect(
          diagnosis.confidence,
          closeTo((sample['expected_confidence'] as num).toDouble(), 1e-6),
        );
        expect(diagnosis.topMatches.length, equals(3));
        expect(diagnosis.topMatches[0].confidence, greaterThan(diagnosis.topMatches[1].confidence));
        expect(diagnosis.topMatches[1].confidence, greaterThan(diagnosis.topMatches[2].confidence));
      }
    });
  });
}
