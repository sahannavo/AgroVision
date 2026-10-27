import 'package:flutter/foundation.dart';

/// Severity level for regional epidemiological outbreak alerts.
enum AlertSeverity {
  high,
  moderate,
  peripheral;

  String get displayName {
    switch (this) {
      case AlertSeverity.high:
        return 'High Risk';
      case AlertSeverity.moderate:
        return 'Moderate Risk';
      case AlertSeverity.peripheral:
        return 'Peripheral Alert';
    }
  }
}

/// Outbreak alert aggregated across local farmer diagnoses.
///
/// PRIVACY GUARANTEE: Never includes farmer identities, user IDs, or exact coordinates.
/// All center points are rounded and represent an approximate geographic cluster radius.
@immutable
class OutbreakAlert {
  final String id;
  final String disease;
  final String crop;
  final String areaLabel;
  final double approxLatitude;
  final double approxLongitude;
  final double radiusKm;
  final int reportCount;
  final int windowDays;
  final AlertSeverity severity;
  final DateTime createdAt;
  final List<String> preventiveSteps;
  final bool isRead;

  const OutbreakAlert({
    required this.id,
    required this.disease,
    required this.crop,
    required this.areaLabel,
    required this.approxLatitude,
    required this.approxLongitude,
    required this.radiusKm,
    required this.reportCount,
    required this.windowDays,
    required this.severity,
    required this.createdAt,
    required this.preventiveSteps,
    this.isRead = false,
  });

  OutbreakAlert copyWith({
    String? id,
    String? disease,
    String? crop,
    String? areaLabel,
    double? approxLatitude,
    double? approxLongitude,
    double? radiusKm,
    int? reportCount,
    int? windowDays,
    AlertSeverity? severity,
    DateTime? createdAt,
    List<String>? preventiveSteps,
    bool? isRead,
  }) {
    return OutbreakAlert(
      id: id ?? this.id,
      disease: disease ?? this.disease,
      crop: crop ?? this.crop,
      areaLabel: areaLabel ?? this.areaLabel,
      approxLatitude: approxLatitude ?? this.approxLatitude,
      approxLongitude: approxLongitude ?? this.approxLongitude,
      radiusKm: radiusKm ?? this.radiusKm,
      reportCount: reportCount ?? this.reportCount,
      windowDays: windowDays ?? this.windowDays,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      preventiveSteps: preventiveSteps ?? this.preventiveSteps,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutbreakAlert &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          disease == other.disease &&
          crop == other.crop &&
          areaLabel == other.areaLabel &&
          approxLatitude == other.approxLatitude &&
          approxLongitude == other.approxLongitude &&
          radiusKm == other.radiusKm &&
          reportCount == other.reportCount &&
          windowDays == other.windowDays &&
          severity == other.severity &&
          createdAt == other.createdAt &&
          listEquals(preventiveSteps, other.preventiveSteps) &&
          isRead == other.isRead;

  @override
  int get hashCode => Object.hash(
        id,
        disease,
        crop,
        areaLabel,
        approxLatitude,
        approxLongitude,
        radiusKm,
        reportCount,
        windowDays,
        severity,
        createdAt,
        Object.hashAll(preventiveSteps),
        isRead,
      );

  @override
  String toString() =>
      'OutbreakAlert(id: $id, disease: $disease, crop: $crop, area: $areaLabel, severity: $severity, read: $isRead)';
}

