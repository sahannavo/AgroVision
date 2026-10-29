import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../domain/weather_forecast.dart';
import '../domain/weather_repository.dart';

/// Firebase-backed production implementation of [WeatherRepository].
///
/// Communicates with the [getWeatherForecast] Cloud Function callable to obtain
/// normalized forecasts with server-side caching and OpenWeatherMap integration.
///
/// Supports full offline resilience:
/// - When connected, calls the Cloud Function callable and updates local cache.
/// - When offline, retrieves the last saved forecast from cache, setting
///   [WeatherForecast.isCached] to true and preserving original [fetchedAt]
///   so screens can display "Using weather saved N hours ago".
class FirebaseWeatherRepository implements WeatherRepository {
  final FirebaseFunctions? functions;
  final FirebaseFirestore? firestore;

  FirebaseWeatherRepository({
    this.functions,
    this.firestore,
  });

  FirebaseFunctions get _effectiveFunctions =>
      functions ?? FirebaseFunctions.instance;

  FirebaseFirestore get _effectiveFirestore =>
      firestore ?? FirebaseFirestore.instance;

  // In-memory cache fallback for instant offline access
  static WeatherForecast? _lastForecast;

  @override
  Future<WeatherForecast> getForecast({
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude ?? 7.4863; // Default to Kurunegala NW agricultural hub
    final lon = longitude ?? 80.3623;

    try {
      final callable = _effectiveFunctions.httpsCallable('getWeatherForecast');
      final result = await callable.call<Map<String, dynamic>>({
        'latitude': lat,
        'longitude': lon,
      });

      final forecast = _parseForecast(result.data, isCached: false);
      _lastForecast = forecast;

      // Asynchronously persist to offline Firestore cache
      _persistLocalCache(lat, lon, forecast);

      return forecast;
    } catch (e) {
      // Offline fallback: check local Firestore cache then in-memory cache
      final cached = await _fetchFromLocalCache(lat, lon);
      if (cached != null) {
        return cached;
      }
      if (_lastForecast != null) {
        return _lastForecast!.copyWith(isCached: true);
      }
      rethrow;
    }
  }

  @override
  Stream<WeatherForecast> watchForecast({
    double? latitude,
    double? longitude,
  }) async* {
    if (_lastForecast != null) {
      yield _lastForecast!.copyWith(isCached: true);
    }

    try {
      final fresh = await getForecast(latitude: latitude, longitude: longitude);
      yield fresh;
    } catch (_) {
      // If error occurs, keep last stream state
    }
  }

  WeatherForecast _parseForecast(Map<String, dynamic> data, {required bool isCached}) {
    final rawDaily = (data['daily'] as List<dynamic>?) ?? [];
    final dailyList = rawDaily.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final rawDate = map['date'];
      final date = rawDate is String
          ? DateTime.tryParse(rawDate) ?? DateTime.now()
          : DateTime.now();

      return DailyForecast(
        date: date,
        high: (map['high'] as num?)?.toDouble() ?? 30.0,
        low: (map['low'] as num?)?.toDouble() ?? 22.0,
        condition: (map['condition'] as String?) ?? 'Scattered Clouds',
        rainChance: (map['rainChance'] as num?)?.toInt() ?? 30,
      );
    }).toList();

    final rawFetchedAt = data['fetchedAt'];
    final fetchedAt = rawFetchedAt is String
        ? DateTime.tryParse(rawFetchedAt) ?? DateTime.now()
        : DateTime.now();

    return WeatherForecast(
      currentTemperature: (data['currentTemperature'] as num?)?.toDouble() ?? 29.0,
      condition: (data['condition'] as String?) ?? 'Scattered Clouds',
      humidity: (data['humidity'] as num?)?.toInt() ?? 85,
      rainChance: (data['rainChance'] as num?)?.toInt() ?? 35,
      daily: dailyList,
      fetchedAt: fetchedAt,
      isCached: isCached || (data['isCached'] == true),
    );
  }

  Future<void> _persistLocalCache(double lat, double lon, WeatherForecast forecast) async {
    try {
      final regionKey = '${lat.toStringAsFixed(1)}_${lon.toStringAsFixed(1)}';
      await _effectiveFirestore.collection('weatherCache').doc(regionKey).set(
        {
          'cacheId': regionKey,
          'regionKey': regionKey,
          'forecastJson': {
            'currentTemperature': forecast.currentTemperature,
            'condition': forecast.condition,
            'humidity': forecast.humidity,
            'rainChance': forecast.rainChance,
            'daily': forecast.daily
                .map((d) => {
                      'date': d.date.toIso8601String(),
                      'high': d.high,
                      'low': d.low,
                      'condition': d.condition,
                      'rainChance': d.rainChance,
                    })
                .toList(),
            'fetchedAt': forecast.fetchedAt.toIso8601String(),
            'isCached': true,
          },
          'fetchedAt': Timestamp.fromDate(forecast.fetchedAt),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Best-effort cache write; do not fail network flow
    }
  }

  Future<WeatherForecast?> _fetchFromLocalCache(double lat, double lon) async {
    try {
      final regionKey = '${lat.toStringAsFixed(1)}_${lon.toStringAsFixed(1)}';
      final doc = await _effectiveFirestore
          .collection('weatherCache')
          .doc(regionKey)
          .get(const GetOptions(source: Source.cache));

      if (doc.exists && doc.data()?['forecastJson'] != null) {
        final json = Map<String, dynamic>.from(doc.data()!['forecastJson'] as Map);
        return _parseForecast(json, isCached: true);
      }
    } catch (_) {
      // Cache lookup failed
    }
    return null;
  }
}
