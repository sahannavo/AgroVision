import 'package:app/features/weather/data/fake_weather_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeWeatherRepository', () {
    test('getForecast returns sample weather matching design specs', () async {
      final repo = FakeWeatherRepository(delay: Duration.zero);
      final forecast = await repo.getForecast();

      expect(forecast.currentTemperature, equals(29.0));
      expect(forecast.condition, equals('Scattered Clouds'));
      expect(forecast.humidity, equals(89));
      expect(forecast.rainChance, equals(40));
      expect(forecast.daily.length, equals(7));
      expect(forecast.isCached, isFalse);
    });

    test('watchForecast emits initial forecast', () async {
      final repo = FakeWeatherRepository(delay: Duration.zero);
      final forecast = await repo.watchForecast().first;

      expect(forecast.currentTemperature, equals(29.0));
      expect(forecast.daily.first.condition, equals('Scattered Clouds'));
    });

    test('offline mode marks forecast as isCached', () async {
      final repo = FakeWeatherRepository(delay: Duration.zero, isOffline: true);
      final forecast = await repo.getForecast();

      expect(forecast.isCached, isTrue);
    });
  });
}

