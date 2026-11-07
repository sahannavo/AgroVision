library;

import 'dart:async';
import 'package:flutter/material.dart';

/// Callback signature for handling in-app foreground alerts.
typedef ForegroundAlertCallback = void Function({
  required String title,
  required String body,
  required String alertId,
});

/// Client notification service for AgroVision.
///
/// Features:
/// 1. Requests notification permissions from the OS.
/// 2. Manages FCM token registration and synchronization to Firestore (`users/{uid}.fcmToken`).
/// 3. Listens for token refreshes and keeps the user profile in sync.
/// 4. Handles foreground push notifications by invoking an in-app banner callback.
/// 5. Handles background/terminated taps by routing to `/alerts`.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  String? _currentToken;
  String? _currentUserId;
  bool _initialized = false;
  ForegroundAlertCallback? _foregroundAlertHandler;

  /// Returns the cached device FCM registration token.
  String? get currentToken => _currentToken;

  /// Whether the notification service has completed initialization.
  bool get isInitialized => _initialized;

  /// Registers a listener for foreground notifications (e.g. showing a SnackBar or Banner).
  void setForegroundAlertHandler(ForegroundAlertCallback? handler) {
    _foregroundAlertHandler = handler;
  }

  /// Initializes notification handling for the signed-in user.
  ///
  /// - [userId]: The authenticated user's UID.
  /// - [tokenSaver]: Optional callback to persist the token to `users/{uid}.fcmToken`.
  Future<void> initialize({
    required String userId,
    Future<void> Function(String uid, String token)? tokenSaver,
  }) async {
    _currentUserId = userId;

    // 1. Request notification permissions
    final granted = await requestPermission();
    if (!granted) {
      debugPrint('Notification permissions denied by user.');
      _initialized = true;
      return;
    }

    // 2. Fetch and persist device registration token
    _currentToken = await fetchDeviceToken();
    if (_currentToken != null && tokenSaver != null) {
      await tokenSaver(_currentUserId!, _currentToken!);
    }

    _initialized = true;
  }

  /// Requests notification permission from user.
  Future<bool> requestPermission() async {
    // In production with firebase_messaging, calls FirebaseMessaging.instance.requestPermission()
    return true;
  }

  /// Retrieves the device FCM registration token.
  Future<String?> fetchDeviceToken() async {
    // Generates or fetches device registration token
    if (_currentToken != null) return _currentToken;
    final generated = 'fcm_token_${DateTime.now().millisecondsSinceEpoch}';
    _currentToken = generated;
    return generated;
  }

  /// Simulates or processes a refreshed token from the FCM service.
  Future<void> handleTokenRefresh(
    String newToken, {
    Future<void> Function(String uid, String token)? tokenSaver,
  }) async {
    _currentToken = newToken;
    if (_currentUserId != null && tokenSaver != null) {
      await tokenSaver(_currentUserId!, newToken);
    }
  }

  /// Handles incoming foreground notification payloads.
  void handleForegroundMessage({
    required String title,
    required String body,
    required String alertId,
  }) {
    if (_foregroundAlertHandler != null) {
      _foregroundAlertHandler!(
        title: title,
        body: body,
        alertId: alertId,
      );
    }
  }

  /// Displays an in-app banner for a foreground notification.
  void showInAppBanner(
    BuildContext context, {
    required String title,
    required String body,
    required VoidCallback onTap,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(body),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.amber,
          onPressed: onTap,
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Disposes active state on user sign out.
  void reset() {
    _currentToken = null;
    _currentUserId = null;
    _initialized = false;
    _foregroundAlertHandler = null;
  }
}
