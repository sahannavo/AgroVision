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

    test('labels.txt matches ml/labels_schema.md in exact 0-indexed order', () {
      final labelsFile = _resolveFile('assets/model/labels.txt');
      expect(labelsFile.existsSync(), isTrue, reason: 'assets/model/labels.txt must exist');

      final labels = labelsFile
          .readAsStringSync()
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      final schemaFile = _resolveFile('ml/labels_schema.md');
      expect(schemaFile.existsSync(), isTrue, reason: 'ml/labels_schema.md must exist');

      final rowRegex = RegExp(r'^\|\s*(\d+)\s*\|\s*`([^`]+)`\s*\|');
      final schemaEntries = <({int index, String label})>[];
      for (final line in schemaFile.readAsLinesSync()) {
        final match = rowRegex.firstMatch(line.trim());
        if (match != null) {
          schemaEntries.add((
            index: int.parse(match.group(1)!),
            label: match.group(2)!.trim(),
          ));
        }
      }

      expect(schemaEntries.length, equals(18));
      expect(labels.length, equals(schemaEntries.length));

      for (var i = 0; i < schemaEntries.length; i++) {
        expect(schemaEntries[i].index, equals(i));
        expect(
          labels[i],
          equals(schemaEntries[i].label),
          reason: 'Label at index $i in labels.txt must match ml/labels_schema.md',
        );
      }
    });

    test('every label in labels.txt has a complete entry in disease_catalog.json', () {
      final labelsFile = _resolveFile('assets/model/labels.txt');
      final labels = labelsFile
          .readAsStringSync()
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      expect(labels.length, equals(18));
      for (final label in labels) {
        expect(
          catalog.containsLabel(label),
          isTrue,
          reason: 'Label "$label" from labels.txt is missing in disease_catalog.json',
        );
        final entry = catalog.lookup(label);
        expect(entry.crop.isNotEmpty, isTrue);
        expect(entry.displayName.isNotEmpty, isTrue);
        expect(entry.scientificName.isNotEmpty, isTrue);
        expect(entry.description.isNotEmpty, isTrue);
        expect(['low', 'moderate', 'high'], contains(entry.severityHint));
        expect(entry.actionSteps.length, equals(3));
        expect(entry.prevention.length, equals(3));
      }

      // Verify the 3 extended Model v2 labels map to expected domain classes
      final chilliCurl = catalog.lookup('Chilli___Leaf_curl');
      expect(chilliCurl.isHealthy, isFalse);
      expect(chilliCurl.diseaseClass, equals(DiseaseClass.leafCurl));

      final eggplantHealthy = catalog.lookup('Eggplant___healthy');
      expect(eggplantHealthy.isHealthy, isTrue);
      expect(eggplantHealthy.diseaseClass, equals(DiseaseClass.healthy));

      final nitrogenDef = catalog.lookup('General___Nitrogen_deficiency');
      expect(nitrogenDef.isHealthy, isFalse);
      expect(nitrogenDef.diseaseClass, equals(DiseaseClass.nitrogenDeficiency));
    });

    test('model.tflite asset exists, is non-empty, and is within size budget', () {
      final modelFile = _resolveFile('assets/model/model.tflite');
      expect(modelFile.existsSync(), isTrue, reason: 'assets/model/model.tflite must exist');
      final sizeBytes = modelFile.lengthSync();
      expect(sizeBytes, greaterThan(0), reason: 'model.tflite must not be empty');
      expect(
        sizeBytes,
        lessThan(10 * 1024 * 1024),
        reason: 'model.tflite should be under the 10 MB target (25 MB hard limit)',
      );
    });
  });
}
