import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Disease Catalog Validation', () {
    late String catalogJson;
    late String labelsContent;

    setUpAll(() {
      final catalogFile = File('assets/data/disease_catalog.json');
      expect(catalogFile.existsSync(), isTrue,
          reason: 'assets/data/disease_catalog.json must exist');
      catalogJson = catalogFile.readAsStringSync();

      final labelsFile = File('assets/model/labels.txt');
      expect(labelsFile.existsSync(), isTrue,
          reason: 'assets/model/labels.txt must exist');
      labelsContent = labelsFile.readAsStringSync();
    });

    test('disease_catalog.json contains valid JSON and required fields', () {
      final decoded = json.decode(catalogJson);
      expect(decoded, isA<List>());
      final list = decoded as List;
      expect(list.isNotEmpty, isTrue);

      for (final item in list) {
        expect(item, isA<Map<String, dynamic>>());
        final map = item as Map<String, dynamic>;

        // Verify mandatory schema fields
        expect(map.containsKey('label'), isTrue);
        expect(map['label'], isA<String>());
        expect((map['label'] as String).isNotEmpty, isTrue);

        expect(map.containsKey('displayName'), isTrue);
        expect((map['displayName'] as String).isNotEmpty, isTrue);

        expect(map.containsKey('scientificName'), isTrue);
        expect((map['scientificName'] as String).isNotEmpty, isTrue);

        expect(map.containsKey('severityHint'), isTrue);
        expect(['low', 'moderate', 'high'], contains(map['severityHint']));

        expect(map.containsKey('description'), isTrue);
        expect((map['description'] as String).length, greaterThan(20));

        expect(map.containsKey('actionSteps'), isTrue);
        expect(map['actionSteps'], isA<List>());
        expect((map['actionSteps'] as List).length, equals(3),
            reason: 'Each entry must provide exactly 3 practical action steps');

        expect(map.containsKey('prevention'), isTrue);
        expect(map['prevention'], isA<List>());
        expect((map['prevention'] as List).length, equals(3),
            reason: 'Each entry must provide exactly 3 prevention tips');

        expect(map.containsKey('isHealthy'), isTrue);
        expect(map['isHealthy'], isA<bool>());
      }
    });

    test('every label in labels.txt is present in disease_catalog.json', () {
      final decoded = json.decode(catalogJson) as List;
      final catalogLabels = decoded
          .map((item) => (item as Map<String, dynamic>)['label'] as String)
          .toSet();

      final rawLabels = labelsContent
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      expect(rawLabels.isNotEmpty, isTrue,
          reason: 'labels.txt must contain at least one label');

      for (final label in rawLabels) {
        expect(catalogLabels.contains(label), isTrue,
            reason: 'Label "$label" from labels.txt is missing in disease_catalog.json');
      }
    });
  });
}
