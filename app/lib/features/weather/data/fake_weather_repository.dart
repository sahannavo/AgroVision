import 'dart:async';
import '../domain/weather_forecast.dart';
import '../domain/weather_repository.dart';

/// Fake implementation of [WeatherRepository] returning realistic sample data
/// matching the design PNGs (29°C · Scattered Clouds, humidity 89%, rain 40%).
class FakeWeatherRepository implements WeatherRepository {
  FakeWeatherRepository({
    this.delay = const Duration(milliseconds: 300),
    this.isOffline = false,
  });

  final Duration delay;
  final bool isOffline;

  WeatherForecast _createSampleForecast() {
    final now = DateTime.now();
    return WeatherForecast(
      currentTemperature: 29.0,
      condition: 'Scattered Clouds',
      humidity: 89,
      rainChance: 40,
      daily: [
        DailyForecast(
          date: now,
          high: 31.0,
          low: 23.0,
          condition: 'Scattered Clouds',
          rainChance: 40,
        ),
        DailyForecast(
          date: now.add(const Duration(days: 1)),
          high: 30.0,
          low: 24.0,
          condition: 'Scattered Showers',
          rainChance: 65,
        ),
        DailyForecast(
          date: now.add(const Duration(days: 2)),
          high: 28.0,
          low: 22.0,
          condition: 'Thunderstorms',
          rainChance: 85,
        ),
        DailyForecast(
          date: now.add(const Duration(days: 3)),
          high: 29.0,
          low: 23.0,
          condition: 'Moderate Rain',
          rainChance: 70,
        ),
        DailyForecast(
          date: now.add(const Duration(days: 4)),
          high: 31.0,
          low: 24.0,
          condition: 'Partly Cloudy',
          rainChance: 30,
        ),
        DailyForecast(
          date: now.add(const Duration(days: 5)),
          high: 32.0,
          low: 24.0,
          condition: 'Sunny',
          rainChance: 15,
        ),
        DailyForecast(
          date: now.add(const Duration(days: 6)),
          high: 31.0,
          low: 23.0,
          condition: 'Scattered Clouds',
          rainChance: 25,
        ),
      ],
      fetchedAt: now.subtract(const Duration(minutes: 12)),
      isCached: isOffline,
    );
  }

  @override
  Future<WeatherForecast> getForecast({
    double? latitude,
    double? longitude,
  }) async {
    await Future<void>.delayed(delay);
    return _createSampleForecast();
  }

  @override
  Stream<WeatherForecast> watchForecast({
    double? latitude,
    double? longitude,
  }) async* {
    await Future<void>.delayed(delay);
    yield _createSampleForecast();
  }
}

