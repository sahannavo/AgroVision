import 'decision_log_entry.dart';
import 'history_stats.dart';

/// Contract for managing history analytics and farmer decision timeline entries.
abstract class HistoryRepository {
  /// Fetches summary analytics across all diagnoses (scans, healthy %, chart data).
  ///
  /// Optional [season] can filter by season (e.g. 'Yala', 'Maha').
  /// Optional [cropType] can filter by crop category (e.g. 'Tomato', 'Chilli').
  Future<HistoryStats> getStats({
    String? userId,
    String? season,
    String? cropType,
  });

  /// Fetches the chronologically ordered decision log timeline entries.
  Future<List<DecisionLogEntry>> getDecisions({String? userId});

  /// Adds a new farmer action or decision log entry.
  Future<DecisionLogEntry> addDecision(DecisionLogEntry entry);
}

