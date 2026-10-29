import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/alerts_repository.dart';
import 'fake_alerts_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [AlertsRepository] instance.
final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return FakeAlertsRepository();
});

