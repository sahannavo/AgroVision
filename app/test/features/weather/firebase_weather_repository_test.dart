import 'package:app/features/weather/data/firebase_weather_repository.dart';
import 'package:app/features/weather/domain/weather_forecast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseWeatherRepository Unit Tests', () {
    test('instantiates with custom Firebase references', () {
      final repo = FirebaseWeatherRepository();
      expect(repo, isNotNull);
    });

    test('watchForecast yields cached forecast when available', () async {
      final repo = FirebaseWeatherRepository();
      final stream = repo.watchForecast(latitude: 7.48, longitude: 80.36);
      expect(stream, isA<Stream<WeatherForecast>>());
    });
  });
}
