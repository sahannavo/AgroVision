import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/alerts/data/firebase_alerts_repository.dart';

void main() {
  group('FirebaseAlertsRepository Unit Tests', () {
    late FirebaseAlertsRepository repository;

    setUp(() {
      repository = FirebaseAlertsRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('watchNearby filters alerts within user radius and sorts newest first', () async {
      // User is located in Kurunegala (7.4818, 80.3609)
      final alertsStream = repository.watchNearby(
        userLat: 7.4818,
        userLon: 80.3609,
        radiusKm: 25.0,
      );

      final alerts = await alertsStream.first;
      expect(alerts, isNotEmpty);

      // Verify Kurunegala alert is included
      final hasKurunegalaAlert = alerts.any(
        (a) => a.diseaseName.contains('Late Blight'),
      );
      expect(hasKurunegalaAlert, isTrue);

      // Verify sorting is newest first
      for (int i = 0; i < alerts.length - 1; i++) {
        expect(
          alerts[i].reportedAt.isAfter(alerts[i + 1].reportedAt) ||
              alerts[i].reportedAt.isAtSameMomentAs(alerts[i + 1].reportedAt),
          isTrue,
        );
      }
    });

    test('watchNearby excludes alerts outside user radius', () async {
      // User located in Jaffna (9.6615, 80.0255) — far from Kurunegala and Dambulla
      final alertsStream = repository.watchNearby(
        userLat: 9.6615,
        userLon: 80.0255,
        radiusKm: 10.0,
      );

      final alerts = await alertsStream.first;
      // Outside radius, so no Kurunegala alerts
      final hasKurunegala = alerts.any((a) => a.id == 'alert-kurunegala-lateblight');
      expect(hasKurunegala, isFalse);
    });

    test('markRead marks alert as read in the stream', () async {
      final initialAlerts = await repository
          .watchNearby(userLat: 7.4818, userLon: 80.3609, radiusKm: 30)
          .first;

      final targetId = initialAlerts.first.id;
      expect(initialAlerts.first.isRead, isFalse);

      await repository.markRead(targetId);

      final updatedCached = repository.getCachedAlerts();
      final markedAlert = updatedCached.firstWhere((a) => a.id == targetId);
      expect(markedAlert.isRead, isTrue);
    });

    test('calculateDistanceKm returns accurate spherical distance', () {
      // Colombo (6.9271, 79.8612) to Kandy (7.2906, 80.6337) is approx 95-115 km
      final dist = FirebaseAlertsRepository.calculateDistanceKm(
        6.9271,
        79.8612,
        7.2906,
        80.6337,
      );

      expect(dist, greaterThan(90));
      expect(dist, lessThan(125));
    });
  });
}
