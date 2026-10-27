import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/history_repository.dart';
import 'fake_history_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [HistoryRepository] instance.
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return FakeHistoryRepository();
});

