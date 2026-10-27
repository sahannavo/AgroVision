import 'package:flutter/foundation.dart';

/// Single day weather forecast entry.
@immutable
class DailyForecast {
  final DateTime date;
  final double high;
  final double low;
  final String condition;
  final int rainChance;

  const DailyForecast({
    required this.date,
    required this.high,
    required this.low,
    required this.condition,
    required this.rainChance,
  });

  DailyForecast copyWith({
    DateTime? date,
    double? high,
    double? low,
    String? condition,
    int? rainChance,
  }) {
    return DailyForecast(
      date: date ?? this.date,
      high: high ?? this.high,
      low: low ?? this.low,
      condition: condition ?? this.condition,
      rainChance: rainChance ?? this.rainChance,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyForecast &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          high == other.high &&
          low == other.low &&
          condition == other.condition &&
          rainChance == other.rainChance;

  @override
  int get hashCode => Object.hash(
        date.year,
        date.month,
        date.day,
        high,
        low,
        condition,
        rainChance,
      );

  @override
  String toString() =>
      'DailyForecast(date: $date, high: $high, low: $low, condition: $condition, rainChance: $rainChance%)';
}

/// Full weather forecast representation for AgroVision.
@immutable
class WeatherForecast {
  final double currentTemperature;
  final String condition;
  final int humidity;
  final int rainChance;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;
  final bool isCached;

  const WeatherForecast({
    required this.currentTemperature,
    required this.condition,
    required this.humidity,
    required this.rainChance,
    required this.daily,
    required this.fetchedAt,
    this.isCached = false,
  });

  WeatherForecast copyWith({
    double? currentTemperature,
    String? condition,
    int? humidity,
    int? rainChance,
    List<DailyForecast>? daily,
    DateTime? fetchedAt,
    bool? isCached,
  }) {
    return WeatherForecast(
      currentTemperature: currentTemperature ?? this.currentTemperature,
      condition: condition ?? this.condition,
      humidity: humidity ?? this.humidity,
      rainChance: rainChance ?? this.rainChance,
      daily: daily ?? this.daily,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isCached: isCached ?? this.isCached,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherForecast &&
          runtimeType == other.runtimeType &&
          currentTemperature == other.currentTemperature &&
          condition == other.condition &&
          humidity == other.humidity &&
          rainChance == other.rainChance &&
          listEquals(daily, other.daily) &&
          fetchedAt == other.fetchedAt &&
          isCached == other.isCached;

  @override
  int get hashCode => Object.hash(
        currentTemperature,
        condition,
        humidity,
        rainChance,
        Object.hashAll(daily),
        fetchedAt,
        isCached,
      );

  @override
  String toString() =>
      'WeatherForecast(temp: $currentTemperature°C, condition: $condition, humidity: $humidity%, rainChance: $rainChance%, cached: $isCached)';
}

