import '../domain/alerts_repository.dart';
import 'fake_alerts_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

final _fakeAlertsRepositoryInstance = FakeAlertsRepository();

/// Provider for [AlertsRepository].
AlertsRepository get alertsRepositoryProvider => _fakeAlertsRepositoryInstance;
