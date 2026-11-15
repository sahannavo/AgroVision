import '../domain/advisor_repository.dart';
import '../domain/crop_suitability_engine.dart';
import '../domain/planting_recommendation.dart';
import '../../weather/domain/weather_repository.dart';

/// Pure offline scoring implementation of [AdvisorRepository].
///
/// Executes the multi-criteria agronomic decision engine [CropSuitabilityEngine].
/// Incorporates cached weather if available from [WeatherRepository]; otherwise
/// smoothly falls back to regional agricultural baseline values.
class LocalAdvisorRepository implements AdvisorRepository {
  final WeatherRepository? weatherRepository;

  const LocalAdvisorRepository({
    this.weatherRepository,
  });

  @override
  Future<List<PlantingRecommendation>> recommend({
    required String soil,
    required String season,
    String? location,
  }) async {
    double? temp;
    int? rain;

    if (weatherRepository != null) {
      try {
        final weather = await weatherRepository!.getForecast();
        temp = weather.currentTemperature;
        rain = weather.rainChance;
      } catch (_) {
        // Missing or unavailable weather cache: engine will fall back to baseline
      }
    }

    final recommendations = CropSuitabilityEngine.evaluate(
      soil: soil,
      season: season,
      currentTemperature: temp,
      rainChance: rain,
    );

    return recommendations;
  }
}
