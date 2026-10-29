import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/weather_forecast.dart';
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

/// Async provider that fetches the latest [WeatherForecast] once on first read.
///
/// Used by [AdvisorScreen] to display the real cached-weather banner (isCached,
/// fetchedAt) without blocking the UI. Safe to watch even in fake mode — the
/// [FakeWeatherRepository] returns a static forecast immediately.
final weatherForecastProvider = FutureProvider<WeatherForecast?>((ref) async {
  final repo = ref.watch(weatherRepositoryProvider);
  try {
    return await repo.getForecast();
  } catch (_) {
    // Offline or no data — UI handles null gracefully (hides banner)
    return null;
  }
});
