import '../domain/history_repository.dart';
import 'fake_history_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

final _fakeHistoryRepositoryInstance = FakeHistoryRepository();

/// Provider for [HistoryRepository].
HistoryRepository get historyRepositoryProvider => _fakeHistoryRepositoryInstance;
