import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../domain/weather_forecast.dart';
import '../domain/weather_repository.dart';

/// Direct Open-Meteo implementation of [WeatherRepository].
///
/// Queries Open-Meteo's free, public API (no API key required) for real-time
/// weather forecasts tailored to Sri Lankan agricultural coordinates.
/// Falls back to offline cached data in Firestore if device loses connection.
class OpenMeteoWeatherRepository implements WeatherRepository {
  final FirebaseFirestore _firestore;

  OpenMeteoWeatherRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static WeatherForecast? _lastForecast;

  @override
  Future<WeatherForecast> getForecast({
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude ?? 7.4863; // Default: Kurunegala
    final lon = longitude ?? 80.3623;

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=$lat&longitude=$lon&'
        'current=temperature_2m,relative_humidity_2m,weather_code&'
        'daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&'
        'timezone=Asia%2FColombo',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>? ?? {};
        final daily = data['daily'] as Map<String, dynamic>? ?? {};

        final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 29.0;
        final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 80;
        final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
        final condition = _wmoToCondition(weatherCode);

        final dailyDates = (daily['time'] as List<dynamic>?) ?? [];
        final dailyMax = (daily['temperature_2m_max'] as List<dynamic>?) ?? [];
        final dailyMin = (daily['temperature_2m_min'] as List<dynamic>?) ?? [];
        final dailyProb = (daily['precipitation_probability_max'] as List<dynamic>?) ?? [];
        final dailyCodes = (daily['weather_code'] as List<dynamic>?) ?? [];

        final List<DailyForecast> dailyList = [];
        for (var i = 0; i < dailyDates.length && i < 7; i++) {
          final dateStr = dailyDates[i].toString();
          final d = DateTime.tryParse(dateStr) ?? DateTime.now().add(Duration(days: i));
          dailyList.add(
            DailyForecast(
              date: d,
              high: (dailyMax.length > i ? (dailyMax[i] as num).toDouble() : temp + 2),
              low: (dailyMin.length > i ? (dailyMin[i] as num).toDouble() : temp - 4),
              condition: _wmoToCondition(dailyCodes.length > i ? (dailyCodes[i] as num).toInt() : 0),
              rainChance: dailyProb.length > i ? (dailyProb[i] as num).toInt() : 30,
            ),
          );
        }

        final rainChance = dailyList.isNotEmpty ? dailyList.first.rainChance : 30;
        final forecast = WeatherForecast(
          currentTemperature: temp,
          condition: condition,
          humidity: humidity,
          rainChance: rainChance,
          daily: dailyList,
          fetchedAt: DateTime.now(),
          isCached: false,
        );

        _lastForecast = forecast;
        _persistCache(lat, lon, forecast);
        return forecast;
      }
    } catch (_) {
      // Fallback to cache on network failure
    }

    final cached = await _fetchFromCache(lat, lon);
    if (cached != null) return cached;
    if (_lastForecast != null) return _lastForecast!.copyWith(isCached: true);

    // Baseline Sri Lankan agricultural climate fallback
    return WeatherForecast(
      currentTemperature: 29.5,
      condition: 'Partly Cloudy',
      humidity: 82,
      rainChance: 35,
      daily: [
        DailyForecast(
          date: DateTime.now(),
          high: 31.0,
          low: 24.0,
          condition: 'Partly Cloudy',
          rainChance: 35,
        ),
      ],
      fetchedAt: DateTime.now(),
      isCached: true,
    );
  }

  @override
  Stream<WeatherForecast> watchForecast({double? latitude, double? longitude}) async* {
    if (_lastForecast != null) yield _lastForecast!;
    try {
      final f = await getForecast(latitude: latitude, longitude: longitude);
      yield f;
    } catch (_) {}
  }

  String _wmoToCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 55) return 'Drizzle';
    if (code <= 65) return 'Rain';
    if (code <= 82) return 'Rain Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Scattered Clouds';
  }

  Future<void> _persistCache(double lat, double lon, WeatherForecast f) async {
    try {
      final key = '${lat.toStringAsFixed(1)}_${lon.toStringAsFixed(1)}';
      await _firestore.collection('weatherCache').doc(key).set({
        'temp': f.currentTemperature,
        'condition': f.condition,
        'humidity': f.humidity,
        'rainChance': f.rainChance,
        'fetchedAt': f.fetchedAt.toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<WeatherForecast?> _fetchFromCache(double lat, double lon) async {
    try {
      final key = '${lat.toStringAsFixed(1)}_${lon.toStringAsFixed(1)}';
      final doc = await _firestore.collection('weatherCache').doc(key).get();
      if (doc.exists && doc.data() != null) {
        final d = doc.data()!;
        return WeatherForecast(
          currentTemperature: (d['temp'] as num?)?.toDouble() ?? 29.0,
          condition: (d['condition'] as String?) ?? 'Partly Cloudy',
          humidity: (d['humidity'] as num?)?.toInt() ?? 80,
          rainChance: (d['rainChance'] as num?)?.toInt() ?? 30,
          daily: [],
          fetchedAt: DateTime.tryParse(d['fetchedAt'] ?? '') ?? DateTime.now(),
          isCached: true,
        );
      }
    } catch (_) {}
    return null;
  }
}
