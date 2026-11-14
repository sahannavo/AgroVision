import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/alerts_repository.dart';
import 'fake_alerts_repository.dart';
import '../domain/outbreak_alert.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [AlertsRepository] instance.
final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return FakeAlertsRepository();
});

class AlertsData {
  const AlertsData({
    required this.alerts,
    required this.lastUpdated,
    required this.userPlot,
    this.seasonSummary = 'Maha season surveillance',
  });

  final List<OutbreakAlert> alerts;
  final DateTime lastUpdated;
  final UserPlotLocation userPlot;
  final String seasonSummary;
}

final alertsDataProvider = FutureProvider<AlertsData>((ref) async {
  final alerts = await ref.watch(alertsRepositoryProvider).getNearby();
  return AlertsData(
    alerts: alerts,
    lastUpdated: DateTime.now(),
    userPlot: const UserPlotLocation(
      latitude: 7.4863,
      longitude: 80.3623,
      plotName: 'Kurunegala plot',
    ),
  );
});
