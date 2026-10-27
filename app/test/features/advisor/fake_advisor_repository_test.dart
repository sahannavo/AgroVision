import 'package:app/features/advisor/data/fake_advisor_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeAdvisorRepository', () {
    test('recommend returns sorted planting recommendations matching designs', () async {
      final repo = FakeAdvisorRepository(delay: Duration.zero);
      final recommendations = await repo.recommend(
        soil: 'Loam',
        season: 'Maha',
        location: 'Kurunegala',
      );

      expect(recommendations.length, equals(4));

      final top = recommendations.first;
      expect(top.crop, contains('Tomato'));
      expect(top.scorePercent, equals(94));
      expect(top.caution, isFalse);
      expect(top.reasonChips, contains('Loam soil ideal'));
      expect(top.harvestDays, equals(75));

      final second = recommendations[1];
      expect(second.crop, contains('Green Chilli'));
      expect(second.scorePercent, equals(88));

      final lowest = recommendations.last;
      expect(lowest.crop, contains('Potato'));
      expect(lowest.scorePercent, equals(62));
      expect(lowest.caution, isTrue);
      expect(lowest.cautionNote, isNotNull);
      expect(lowest.cautionNote, contains('Too warm'));
    });
  });
}

