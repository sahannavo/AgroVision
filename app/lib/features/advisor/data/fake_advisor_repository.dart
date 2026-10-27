import '../domain/advisor_repository.dart';
import '../domain/planting_recommendation.dart';

/// Fake implementation of [AdvisorRepository] returning sample recommendations
/// matching the design PNGs (Tomato 94%, Green Chilli 88%, Brinjal 85%, Potato 62%).
class FakeAdvisorRepository implements AdvisorRepository {
  FakeAdvisorRepository({
    this.delay = const Duration(milliseconds: 300),
  });

  final Duration delay;

  @override
  Future<List<PlantingRecommendation>> recommend({
    required String soil,
    required String season,
    String? location,
  }) async {
    await Future<void>.delayed(delay);

    return const [
      PlantingRecommendation(
        crop: 'Tomato (Thilina)',
        scientificName: 'Solanum lycopersicum',
        scorePercent: 94,
        reasonChips: [
          'Loam soil ideal',
          'Maha season fit',
          'High local demand',
        ],
        harvestDays: 75,
        caution: false,
      ),
      PlantingRecommendation(
        crop: 'Green Chilli (MICH 1)',
        scientificName: 'Capsicum annuum',
        scorePercent: 88,
        reasonChips: [
          'Well-draining loam',
          'Optimal temperature (28-32°C)',
          'Extended harvesting cycle',
        ],
        harvestDays: 90,
        caution: false,
      ),
      PlantingRecommendation(
        crop: 'Brinjal (Padagoda)',
        scientificName: 'Solanum melongena',
        scorePercent: 85,
        reasonChips: [
          'High pest resilience',
          'Consistent fruiting',
        ],
        harvestDays: 80,
        caution: false,
      ),
      PlantingRecommendation(
        crop: 'Potato (Granola)',
        scientificName: 'Solanum tuberosum',
        scorePercent: 62,
        reasonChips: [
          'Prefers cooler hill-country',
        ],
        harvestDays: 105,
        caution: true,
        cautionNote: 'Too warm in Kurunegala lowland. Risk of poor tuber initiation and bacterial wilt.',
      ),
    ];
  }
}
