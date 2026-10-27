import 'outbreak_alert.dart';

/// Contract for watching and managing regional outbreak alerts.
abstract class AlertsRepository {
  /// Watches active outbreak alerts near the specified or user location.
  Stream<List<OutbreakAlert>> watchNearby({
    double? latitude,
    double? longitude,
    double? radiusKm,
  });

  /// Fetches active outbreak alerts near the location.
  Future<List<OutbreakAlert>> getNearby({
    double? latitude,
    double? longitude,
    double? radiusKm,
  });

  /// Marks an alert as read by the user.
  Future<void> markRead(String alertId);
}
