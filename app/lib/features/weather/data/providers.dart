import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/weather_repository.dart';
import 'fake_weather_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [WeatherRepository] instance.
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return FakeWeatherRepository();
});

