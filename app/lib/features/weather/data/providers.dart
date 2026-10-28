import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/weather_repository.dart';
import 'fake_weather_repository.dart';
import 'firebase_weather_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [WeatherRepository] instance.
///
/// Uses [FakeWeatherRepository] by default when developing locally or running UI tests.
/// Switches to [FirebaseWeatherRepository] when built with `--dart-define=USE_FAKES=false`.
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  if (kUseFakes) {
    return FakeWeatherRepository();
  }
  return FirebaseWeatherRepository();
});
