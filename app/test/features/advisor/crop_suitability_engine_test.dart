import 'package:app/features/advisor/data/local_advisor_repository.dart';
import 'package:app/features/advisor/domain/crop_suitability_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CropSuitabilityEngine & LocalAdvisorRepository Tests', () {
    test('loam in Yala ranks Tomato and Chilli above Potato', () {
      final results = CropSuitabilityEngine.evaluate(
        soil: 'Loam',
        season: 'Yala',
        currentTemperature: 29.5,
        rainChance: 40,
      );

      expect(results.length, equals(4));

      final tomatoIndex = results.indexWhere((r) => r.crop == 'Tomato');
      final chilliIndex = results.indexWhere((r) => r.crop == 'Chilli');
      final potatoIndex = results.indexWhere((r) => r.crop == 'Potato');

      expect(tomatoIndex, lessThan(potatoIndex));
      expect(chilliIndex, lessThan(potatoIndex));

      // Potato has thermal caution in warm Yala lowland conditions
      final potato = results[potatoIndex];
      expect(potato.caution, isTrue);
      expect(potato.cautionNote, isNotNull);
      expect(potato.cautionNote, contains('Too warm'));
    });

    test('missing weather cache still returns valid results', () async {
      // LocalAdvisorRepository without weatherRepository instance
      const repo = LocalAdvisorRepository(weatherRepository: null);
      final results = await repo.recommend(
        soil: 'Clay',
        season: 'Maha',
      );

      expect(results, isNotEmpty);
      expect(results.length, equals(4));
    });

    test('all scores are always guaranteed between 0 and 100', () {
      final testCases = [
        {'soil': 'Clay', 'season': 'Maha', 'temp': 12.0, 'rain': 10},
        {'soil': 'Sandy', 'season': 'Yala', 'temp': 38.0, 'rain': 90},
        {'soil': 'Loam', 'season': 'Yala', 'temp': 28.0, 'rain': 45},
        {'soil': 'Silt', 'season': 'Maha', 'temp': 22.0, 'rain': 50},
      ];

      for (final tc in testCases) {
        final results = CropSuitabilityEngine.evaluate(
          soil: tc['soil'] as String,
          season: tc['season'] as String,
          currentTemperature: tc['temp'] as double,
          rainChance: tc['rain'] as int,
        );

        for (final rec in results) {
          expect(rec.scorePercent, greaterThanOrEqualTo(0));
          expect(rec.scorePercent, lessThanOrEqualTo(100));
        }
      }
    });

    test('scoring weights sum up to exactly 100%', () {
      final sum = AdvisorScoringWeights.soilWeight +
          AdvisorScoringWeights.seasonWeight +
          AdvisorScoringWeights.temperatureWeight +
          AdvisorScoringWeights.rainWeight;
      expect(sum, equals(AdvisorScoringWeights.totalMaxScore));
    });
  });
}
