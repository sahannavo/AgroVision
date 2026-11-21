import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/diagnosis/data/disease_catalog.dart';
import 'package:app/features/diagnosis/domain/disease_class.dart';

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
  group('DiseaseCatalog Tests', () {
    late String catalogJson;
    late DiseaseCatalog catalog;

    setUpAll(() {
      final file = _resolveFile('assets/data/disease_catalog.json');
      expect(file.existsSync(), isTrue, reason: 'assets/data/disease_catalog.json must exist');
      catalogJson = file.readAsStringSync();
      catalog = DiseaseCatalog.fromJsonString(catalogJson);
    });

    test('loads all 18 canonical classes from disease_catalog.json', () {
      expect(catalog.length, equals(18));
      expect(catalog.containsLabel('Tomato___Early_blight'), isTrue);
      expect(catalog.containsLabel('Tomato___healthy'), isTrue);
      expect(catalog.containsLabel('Potato___Late_blight'), isTrue);
      expect(catalog.containsLabel('Pepper___Bacterial_spot'), isTrue);
      expect(catalog.containsLabel('Chilli___Leaf_curl'), isTrue);
      expect(catalog.containsLabel('Eggplant___healthy'), isTrue);
      expect(catalog.containsLabel('General___Nitrogen_deficiency'), isTrue);
    });

    test('lookup returns accurate agronomic details for a known label', () {
      final entry = catalog.lookup('Tomato___Early_blight');
      expect(entry.label, equals('Tomato___Early_blight'));
      expect(entry.crop, equals('Tomato'));
      expect(entry.displayName, equals('Early Blight'));
      expect(entry.scientificName, equals('Alternaria solani'));
      expect(entry.severityHint, equals('moderate'));
      expect(entry.actionSteps.length, equals(3));
      expect(entry.prevention.length, equals(3));
      expect(entry.isHealthy, isFalse);
      expect(entry.diseaseClass, equals(DiseaseClass.earlyBlight));

      final diseaseInfo = entry.toDiseaseInfo();
      expect(diseaseInfo.displayName, equals('Early Blight'));
      expect(diseaseInfo.scientificName, equals('Alternaria solani'));
      expect(diseaseInfo.isHealthy, isFalse);
    });

    test('lookup handles unknown label with safe generic fallback and never crashes', () {
      const unknownLabel = 'UnknownCrop___Mysterious_blight';
      final entry = catalog.lookup(unknownLabel);

      expect(entry.label, equals(unknownLabel));
      expect(entry.crop, equals('UnknownCrop'));
      expect(entry.displayName.isNotEmpty, isTrue);
      expect(entry.scientificName.isNotEmpty, isTrue);
      expect(entry.description.isNotEmpty, isTrue);
      expect(entry.actionSteps.isNotEmpty, isTrue);
      expect(entry.prevention.isNotEmpty, isTrue);
      expect(entry.isHealthy, isFalse);
      expect(entry.diseaseClass, isA<DiseaseClass>());

      final info = entry.toDiseaseInfo();
      expect(info, isNotNull);
      expect(info.recommendedActionSteps, isNotEmpty);
    });

    test('lookup handles unknown healthy label gracefully', () {
      const unknownHealthy = 'Dragonfruit___healthy';
      final entry = catalog.lookup(unknownHealthy);

      expect(entry.isHealthy, isTrue);
      expect(entry.diseaseClass, equals(DiseaseClass.healthy));
      expect(entry.toDiseaseInfo().isHealthy, isTrue);
    });

    test('correctly maps 18 labels to domain DiseaseClass enum without throws', () {
      for (final label in catalog.labels) {
        final entry = catalog.lookup(label);
        expect(entry.diseaseClass, isNotNull);
        expect(entry.toDiseaseInfo(), isNotNull);
      }
    });
  });
}
