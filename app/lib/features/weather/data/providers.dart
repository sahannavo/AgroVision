import '../domain/weather_repository.dart';
import 'fake_weather_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

final _fakeWeatherRepositoryInstance = FakeWeatherRepository();

/// Provider for [WeatherRepository].
/// Screens read weather data exclusively through this provider.
WeatherRepository get weatherRepositoryProvider => _fakeWeatherRepositoryInstance;
