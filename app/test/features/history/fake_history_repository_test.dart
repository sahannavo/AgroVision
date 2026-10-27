import 'package:app/features/diagnosis/domain/diagnosis.dart';
import 'package:app/features/history/data/fake_history_repository.dart';
import 'package:app/features/history/domain/decision_log_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeHistoryRepository', () {
    test('getStats returns analytics matching design PNGs', () async {
      final repo = FakeHistoryRepository(delay: Duration.zero);
      final stats = await repo.getStats();

      expect(stats.totalScans, equals(24));
      expect(stats.healthyPercent, equals(75));
      expect(stats.topIssue, equals('Early Blight'));
      expect(stats.weeklyScans.length, equals(8));
      expect(stats.diseaseBreakdown['Healthy'], equals(18));
      expect(stats.diseaseBreakdown['Early Blight'], equals(4));
    });

    test('getDecisions returns timeline records', () async {
      final repo = FakeHistoryRepository(delay: Duration.zero);
      final decisions = await repo.getDecisions();

      expect(decisions.length, equals(3));
      expect(decisions.first.title, contains('Copper Hydroxide'));
      expect(decisions.first.resultLabel, equals('Completed'));
      expect(decisions.first.syncStatus, equals(SyncStatus.synced));
    });

    test('addDecision appends new decision entry', () async {
      final repo = FakeHistoryRepository(delay: Duration.zero);
      final newEntry = DecisionLogEntry(
        id: 'dec_test_04',
        userId: 'farmer_nimal_01',
        date: DateTime.now(),
        title: 'Installed yellow sticky traps',
        detail: 'Set 10 traps to monitor whitefly activity',
        resultLabel: 'Pending sync',
        syncStatus: SyncStatus.pending,
      );

      await repo.addDecision(newEntry);
      final decisions = await repo.getDecisions();
      expect(decisions.first.id, equals('dec_test_04'));
      expect(decisions.first.syncStatus, equals(SyncStatus.pending));
    });
  });
}
