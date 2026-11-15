import 'dart:async';
import '../domain/alerts_repository.dart';
import '../domain/outbreak_alert.dart';

/// Fake implementation of [AlertsRepository] returning realistic outbreak alerts
/// matching the design PNGs (Kurunegala District Alert, 8 reports, Early Blight).
class FakeAlertsRepository implements AlertsRepository {
  FakeAlertsRepository({
    this.delay = const Duration(milliseconds: 300),
  }) {
    _alerts = List.of(_initialSampleAlerts);
    _controller = StreamController<List<OutbreakAlert>>.broadcast(
      onListen: () => _controller.add(List.unmodifiable(_alerts)),
    );
  }

  final Duration delay;
  late final List<OutbreakAlert> _alerts;
  late final StreamController<List<OutbreakAlert>> _controller;

  static List<OutbreakAlert> get _initialSampleAlerts {
    final now = DateTime.now();
    return [
      OutbreakAlert(
        id: 'alert_kurunegala_01',
        disease: 'Early Blight',
        crop: 'Tomato & Chilli',
        areaLabel: 'Kurunegala (North Western Zone)',
        approxLatitude: 7.4863,
        approxLongitude: 80.3623,
        radiusKm: 15.0,
        reportCount: 8,
        windowDays: 2,
        severity: AlertSeverity.high,
        createdAt: now.subtract(const Duration(hours: 3)),
        preventiveSteps: const [
          'Inspect lower leaves for dark concentric spots.',
          'Apply protective copper-based fungicide spray early morning.',
          'Avoid overhead sprinkler watering to minimize leaf wetness duration.',
          'Maintain 45cm spacing between beds for air circulation.',
        ],
        isRead: false,
      ),
      OutbreakAlert(
        id: 'alert_dambulla_02',
        disease: 'Late Blight',
        crop: 'Potato',
        areaLabel: 'Dambulla Outskirts',
        approxLatitude: 7.8731,
        approxLongitude: 80.6517,
        radiusKm: 25.0,
        reportCount: 4,
        windowDays: 5,
        severity: AlertSeverity.moderate,
        createdAt: now.subtract(const Duration(days: 2)),
        preventiveSteps: const [
          'Monitor field borders facing windward monsoon direction.',
          'Ensure drainage channels are clear of standing water.',
          'Report any water-soaked dark leaf lesions immediately.',
        ],
        isRead: true,
      ),
    ];
  }

  @override
  Stream<List<OutbreakAlert>> watchNearby({
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) =>
      _controller.stream;

  @override
  Future<List<OutbreakAlert>> getNearby({
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    await Future<void>.delayed(delay);
    return List.unmodifiable(_alerts);
  }

  @override
  Future<void> markRead(String alertId) async {
    await Future<void>.delayed(delay);
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isRead: true);
      _controller.add(List.unmodifiable(_alerts));
    }
  }

  void dispose() {
    _controller.close();
  }
}

