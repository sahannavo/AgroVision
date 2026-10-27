import 'package:app/features/alerts/data/fake_alerts_repository.dart';
import 'package:app/features/alerts/domain/outbreak_alert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeAlertsRepository', () {
    late FakeAlertsRepository repo;

    setUp(() {
      repo = FakeAlertsRepository(delay: Duration.zero);
    });

    tearDown(() {
      repo.dispose();
    });

    test('getNearby returns outbreak clusters from design PNGs', () async {
      final alerts = await repo.getNearby();
      expect(alerts.length, equals(2));

      final highRisk = alerts.first;
      expect(highRisk.disease, equals('Early Blight'));
      expect(highRisk.crop, contains('Tomato & Chilli'));
      expect(highRisk.areaLabel, contains('Kurunegala'));
      expect(highRisk.reportCount, equals(8));
      expect(highRisk.radiusKm, equals(15.0));
      expect(highRisk.severity, equals(AlertSeverity.high));
      expect(highRisk.preventiveSteps, isNotEmpty);
      expect(highRisk.isRead, isFalse);

      final moderate = alerts.last;
      expect(moderate.severity, equals(AlertSeverity.moderate));
      expect(moderate.isRead, isTrue);
    });

    test('markRead marks the alert as read and notifies listeners', () async {
      final alertsBefore = await repo.getNearby();
      final targetId = alertsBefore.first.id;
      expect(alertsBefore.first.isRead, isFalse);

      await repo.markRead(targetId);
      final alertsAfter = await repo.getNearby();
      final updated = alertsAfter.firstWhere((a) => a.id == targetId);
      expect(updated.isRead, isTrue);
    });
  });
}

