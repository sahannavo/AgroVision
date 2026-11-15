import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/services/notification_service.dart';

void main() {
  group('NotificationService Unit Tests', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService();
      service.reset();
    });

    test('initializes and saves token with tokenSaver callback', () async {
      String? savedUid;
      String? savedToken;

      await service.initialize(
        userId: 'farmer_alice_99',
        tokenSaver: (uid, token) async {
          savedUid = uid;
          savedToken = token;
        },
      );

      expect(service.isInitialized, isTrue);
      expect(service.currentToken, isNotNull);
      expect(savedUid, 'farmer_alice_99');
      expect(savedToken, isNotNull);
    });

    test('handleTokenRefresh triggers token persistence with new token', () async {
      String? refreshedToken;

      await service.initialize(userId: 'farmer_bob_12');

      await service.handleTokenRefresh(
        'fcm_new_token_test_123',
        tokenSaver: (uid, token) async {
          refreshedToken = token;
        },
      );

      expect(service.currentToken, 'fcm_new_token_test_123');
      expect(refreshedToken, 'fcm_new_token_test_123');
    });

    test('handleForegroundMessage calls registered alert handler', () {
      String? capturedTitle;
      String? capturedAlertId;

      service.setForegroundAlertHandler(({
        required String title,
        required String body,
        required String alertId,
      }) {
        capturedTitle = title;
        capturedAlertId = alertId;
      });

      service.handleForegroundMessage(
        title: 'Disease Alert: Late Blight',
        body: 'Outbreak reported within 15km',
        alertId: 'alert_101',
      );

      expect(capturedTitle, 'Disease Alert: Late Blight');
      expect(capturedAlertId, 'alert_101');
    });
  });
}
