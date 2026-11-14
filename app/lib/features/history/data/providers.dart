import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../diagnosis/data/providers.dart';
import '../domain/decision_log_entry.dart';
import '../domain/history_repository.dart';
import '../domain/history_stats.dart';
import 'fake_history_repository.dart';
import 'firebase_history_repository.dart';

/// Configuration flag to switch between fake and real Firebase history implementations.
/// Defaults to true so the front-end team can continue working without Firebase.
/// Switch to false by compiling with `--dart-define=USE_FAKES=false`.
const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [HistoryRepository] instance.
///
/// Returns [FakeHistoryRepository] when `USE_FAKES=true`.
/// Returns [FirebaseHistoryRepository] connected to Firestore and [diagnosisRepositoryProvider]
/// when `USE_FAKES=false`.
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  if (kUseFakes) {
    return FakeHistoryRepository();
  }

  final diagnosisRepository = ref.watch(diagnosisRepositoryProvider);
  return FirebaseHistoryRepository(
    diagnosisRepository: diagnosisRepository,
    firestore: FirebaseFirestore.instance,
    currentUserIdProvider: () => FirebaseAuth.instance.currentUser?.uid,
  );
});

/// Async provider for fetching [HistoryStats] for the current user.
final historyStatsProvider = FutureProvider<HistoryStats>((ref) async {
  final historyRepo = ref.watch(historyRepositoryProvider);
  return historyRepo.getStats();
});

/// Async provider for fetching the list of [DecisionLogEntry] items.
final decisionLogsProvider = FutureProvider<List<DecisionLogEntry>>((ref) async {
  final historyRepo = ref.watch(historyRepositoryProvider);
  return historyRepo.getDecisions();
});
