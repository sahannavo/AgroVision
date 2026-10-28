import '../../diagnosis/domain/diagnosis.dart';
import '../domain/decision_log_entry.dart';
import '../domain/history_repository.dart';
import '../domain/history_stats.dart';

/// Fake implementation of [HistoryRepository] returning analytics and decision timeline
/// matching the design PNGs (24 scans, 75% healthy, Early Blight issue, decision log).
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository({
    this.delay = const Duration(milliseconds: 300),
  }) {
    _decisions = List.of(_initialSampleDecisions);
  }

  final Duration delay;
  late final List<DecisionLogEntry> _decisions;

  static List<DecisionLogEntry> get _initialSampleDecisions {
    final now = DateTime.now();
    return [
      DecisionLogEntry(
        id: 'dec_01',
        userId: 'farmer_nimal_01',
        cropId: 'plot_tomato_01',
        date: now.subtract(const Duration(hours: 4)),
        title: 'Applied Copper Hydroxide (0.2%) fungicide spray',
        detail:
            'Treated Tomato Bed #2 following Early Blight alert. Applied in early morning under dry leaves.',
        resultLabel: 'Completed',
        syncStatus: SyncStatus.synced,
      ),
      DecisionLogEntry(
        id: 'dec_02',
        userId: 'farmer_nimal_01',
        cropId: 'plot_tomato_01',
        date: now.subtract(const Duration(days: 2)),
        title: 'Skipped evening irrigation due to rain',
        detail:
            'Weather station reported 45mm rainfall in Kurunegala North; skipped watering to avoid root-rot.',
        resultLabel: 'Optimized',
        syncStatus: SyncStatus.synced,
      ),
      DecisionLogEntry(
        id: 'dec_03',
        userId: 'farmer_nimal_01',
        cropId: 'plot_chilli_01',
        date: now.subtract(const Duration(days: 5)),
        title: 'Straw mulch applied on chilli terraces',
        detail:
            'Covered Bed #4 root beds with dry straw mulch to suppress weed germination and conserve moisture.',
        resultLabel: 'Pending sync',
        syncStatus: SyncStatus.pending,
      ),
    ];
  }

  @override
  Future<HistoryStats> getStats({String? userId}) async {
    await Future<void>.delayed(delay);

    return const HistoryStats(
      totalScans: 24,
      healthyPercent: 75,
      topIssue: 'Early Blight',
      weeklyScans: {
        'W1': 2,
        'W2': 3,
        'W3': 1,
        'W4': 4,
        'W5': 2,
        'W6': 3,
        'W7': 4,
        'W8': 5,
      },
      diseaseBreakdown: {
        'Healthy': 18,
        'Early Blight': 4,
        'Late Blight': 1,
        'Leaf Curl': 1,
      },
    );
  }

  @override
  Future<List<DecisionLogEntry>> getDecisions({String? userId}) async {
    await Future<void>.delayed(delay);
    return List.unmodifiable(_decisions);
  }

  @override
  Future<DecisionLogEntry> addDecision(DecisionLogEntry entry) async {
    await Future<void>.delayed(delay);
    _decisions.insert(0, entry);
    return entry;
  }
}

