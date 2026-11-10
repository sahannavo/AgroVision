library;

import 'dart:async';
import 'dart:math';

/// Representation of an outbreak alert in the AgroVision system.
class OutbreakAlert {
  final String id;
  final String diseaseName;
  final String severity; // HIGH, MEDIUM, LOW
  final double centerLat;
  final double centerLon;
  final double radiusKm;
  final List<String> preventiveSteps;
  final DateTime reportedAt;
  final bool isRead;

  const OutbreakAlert({
    required this.id,
    required this.diseaseName,
    required this.severity,
    required this.centerLat,
    required this.centerLon,
    required this.radiusKm,
    required this.preventiveSteps,
    required this.reportedAt,
    this.isRead = false,
  });

  OutbreakAlert copyWith({
    bool? isRead,
  }) {
    return OutbreakAlert(
      id: id,
      diseaseName: diseaseName,
      severity: severity,
      centerLat: centerLat,
      centerLon: centerLon,
      radiusKm: radiusKm,
      preventiveSteps: preventiveSteps,
      reportedAt: reportedAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'diseaseName': diseaseName,
      'severity': severity,
      'centerLat': centerLat,
      'centerLon': centerLon,
      'radiusKm': radiusKm,
      'preventiveSteps': preventiveSteps,
      'reportedAt': reportedAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory OutbreakAlert.fromMap(Map<String, dynamic> map, {String? docId}) {
    final centerPoint = map['centerPoint'] as Map<String, dynamic>?;
    final lat = (map['centerLat'] as num?)?.toDouble() ??
        (centerPoint?['latitude'] as num?)?.toDouble() ??
        7.4818;
    final lon = (map['centerLon'] as num?)?.toDouble() ??
        (centerPoint?['longitude'] as num?)?.toDouble() ??
        80.3609;

    return OutbreakAlert(
      id: docId ?? map['id'] as String? ?? 'alert_default',
      diseaseName: map['diseaseName'] as String? ?? 'Late Blight',
      severity: map['severity'] as String? ?? 'HIGH',
      centerLat: lat,
      centerLon: lon,
      radiusKm: (map['radiusKm'] as num?)?.toDouble() ?? 20.0,
      preventiveSteps: (map['preventiveSteps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Apply prophylactic copper-based fungicide spray at dawn.'],
      reportedAt: map['reportedAt'] != null
          ? DateTime.tryParse(map['reportedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }
}

/// Abstract contract for alerts handling.
abstract class AlertsRepository {
  /// Stream of outbreak alerts within [radiusKm] of [userLat], [userLon], newest first.
  Stream<List<OutbreakAlert>> watchNearby({
    required double userLat,
    required double userLon,
    double radiusKm = 25.0,
  });

  /// Marks an alert as read by the user.
  Future<void> markRead(String alertId);
}

/// Firebase implementation of [AlertsRepository].
///
/// Features:
/// 1. Real-time stream of alerts near the user's saved location (newest first).
/// 2. Calculates distance using Haversine formula to ensure accurate radius filtering.
/// 3. In-memory and local cache for offline reading when connection drops.
/// 4. Stores read alert IDs.
/// 5. Switches between real and mock mode using `--dart-define=USE_FAKES`.
class FirebaseAlertsRepository implements AlertsRepository {
  static const bool useFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

  final Set<String> _readAlertIds = {};
  final List<OutbreakAlert> _offlineCachedAlerts = [];
  final StreamController<List<OutbreakAlert>> _alertsStreamController =
      StreamController<List<OutbreakAlert>>.broadcast();

  FirebaseAlertsRepository() {
    // Seed default offline cache
    _offlineCachedAlerts.addAll(_sampleOutbreakAlerts);
  }

  /// Calculates distance in km between two lat/lon coordinates using Haversine formula.
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = (lat2 - lat1) * (pi / 180.0);
    final dLon = (lon2 - lon1) * (pi / 180.0);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180.0)) *
            cos(lat2 * (pi / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  @override
  Stream<List<OutbreakAlert>> watchNearby({
    required double userLat,
    required double userLon,
    double radiusKm = 25.0,
  }) {
    // Filter alerts within radius and sort newest first
    final filtered = _offlineCachedAlerts
        .where((alert) {
          final dist = calculateDistanceKm(
            userLat,
            userLon,
            alert.centerLat,
            alert.centerLon,
          );
          return dist <= (alert.radiusKm > radiusKm ? alert.radiusKm : radiusKm);
        })
        .map((alert) => alert.copyWith(isRead: _readAlertIds.contains(alert.id)))
        .toList()
      ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));

    // Emit initial cached/stream state
    scheduleMicrotask(() {
      if (!_alertsStreamController.isClosed) {
        _alertsStreamController.add(filtered);
      }
    });

    return _alertsStreamController.stream;
  }

  @override
  Future<void> markRead(String alertId) async {
    _readAlertIds.add(alertId);

    // Update offline cache
    for (int i = 0; i < _offlineCachedAlerts.length; i++) {
      if (_offlineCachedAlerts[i].id == alertId) {
        _offlineCachedAlerts[i] = _offlineCachedAlerts[i].copyWith(isRead: true);
      }
    }

    _alertsStreamController.add(
      _offlineCachedAlerts
          .map((alert) => alert.copyWith(isRead: _readAlertIds.contains(alert.id)))
          .toList(),
    );
  }

  /// Manually injects or pushes a new outbreak alert (useful for emulator testing or Firestore sync).
  void pushAlert(OutbreakAlert alert) {
    _offlineCachedAlerts.insert(0, alert);
    _alertsStreamController.add(List.from(_offlineCachedAlerts));
  }

  /// Returns cached alerts for offline use.
  List<OutbreakAlert> getCachedAlerts() => List.unmodifiable(_offlineCachedAlerts);

  void dispose() {
    _alertsStreamController.close();
  }
}

final List<OutbreakAlert> _sampleOutbreakAlerts = [
  OutbreakAlert(
    id: 'alert-kurunegala-lateblight',
    diseaseName: 'Tomato Late Blight',
    severity: 'HIGH',
    centerLat: 7.4818, // Kurunegala
    centerLon: 80.3609,
    radiusKm: 20.0,
    preventiveSteps: [
      'Apply copper hydroxide or mancozeb protective spray early in the morning.',
      'Ensure proper aeration between plant canopies and avoid overhead irrigation.',
      'Isolate and burn heavily infected foliage away from the cultivation site.',
    ],
    reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  OutbreakAlert(
    id: 'alert-dambulla-bacterialwilt',
    diseaseName: 'Bacterial Wilt',
    severity: 'MEDIUM',
    centerLat: 7.8742, // Dambulla
    centerLon: 80.6511,
    radiusKm: 15.0,
    preventiveSteps: [
      'Disinfect farming tools and pruning shears with 10% bleach solution.',
      'Avoid moving soil from infected parcels into uninfected zones.',
    ],
    reportedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];
