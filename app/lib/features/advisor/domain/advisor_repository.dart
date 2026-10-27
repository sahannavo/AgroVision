import 'planting_recommendation.dart';

/// Contract for generating crop suitability and planting recommendations.
abstract class AdvisorRepository {
  /// Evaluates soil type, season, and geographical location to suggest crops.
  Future<List<PlantingRecommendation>> recommend({
    required String soil,
    required String season,
    String? location,
  });
}
