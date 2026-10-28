import 'package:flutter/foundation.dart';

/// Aggregated history statistics for the History and Analytics dashboard.
@immutable
class HistoryStats {
  final int totalScans;
  final int healthyPercent;
  final String topIssue;
  final Map<String, int> weeklyScans;
  final Map<String, int> diseaseBreakdown;

  const HistoryStats({
    required this.totalScans,
    required this.healthyPercent,
    required this.topIssue,
    required this.weeklyScans,
    required this.diseaseBreakdown,
  });

  HistoryStats copyWith({
    int? totalScans,
    int? healthyPercent,
    String? topIssue,
    Map<String, int>? weeklyScans,
    Map<String, int>? diseaseBreakdown,
  }) {
    return HistoryStats(
      totalScans: totalScans ?? this.totalScans,
      healthyPercent: healthyPercent ?? this.healthyPercent,
      topIssue: topIssue ?? this.topIssue,
      weeklyScans: weeklyScans ?? this.weeklyScans,
      diseaseBreakdown: diseaseBreakdown ?? this.diseaseBreakdown,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryStats &&
          runtimeType == other.runtimeType &&
          totalScans == other.totalScans &&
          healthyPercent == other.healthyPercent &&
          topIssue == other.topIssue &&
          mapEquals(weeklyScans, other.weeklyScans) &&
          mapEquals(diseaseBreakdown, other.diseaseBreakdown);

  @override
  int get hashCode => Object.hash(
        totalScans,
        healthyPercent,
        topIssue,
        Object.hashAll(weeklyScans.entries),
        Object.hashAll(diseaseBreakdown.entries),
      );

  @override
  String toString() =>
      'HistoryStats(scans: $totalScans, healthy: $healthyPercent%, topIssue: $topIssue)';
}

