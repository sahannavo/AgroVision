import 'weather_forecast.dart';

/// Contract for fetching and watching weather forecasts.
abstract class WeatherRepository {
  /// Fetches the latest weather forecast for the given or user location.
  Future<WeatherForecast> getForecast({
    double? latitude,
    double? longitude,
  });

  /// Watches periodic or cached forecast updates.
  Stream<WeatherForecast> watchForecast({
    double? latitude,
    double? longitude,
  });
}
