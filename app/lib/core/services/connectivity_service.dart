import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service responsible for monitoring and checking internet connectivity.
///
/// Example usage:
/// ```dart
/// final service = ConnectivityService();
/// final isOnline = await service.isOnline;
/// service.onConnectivityChanged.listen((online) {
///   debugPrint('Online status: $online');
/// });
/// ```
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Converts a list of [ConnectivityResult] into a boolean indicating if the device is online.
  ///
  /// Any connection other than [ConnectivityResult.none] is considered online.
  static bool isOnlineFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) => result != ConnectivityResult.none);
  }

  /// Checks current connectivity and returns whether the device is online.
  Future<bool> get isOnline async {
    try {
      final results = await _connectivity.checkConnectivity();
      return isOnlineFromResults(results);
    } catch (_) {
      return false;
    }
  }

  /// Stream of online status updates. Emits `true` when online, `false` when offline.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .map(isOnlineFromResults)
        .distinct();
  }
}

/// Provider for the [ConnectivityService] instance.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// A Riverpod Notifier that monitors network connectivity using [ConnectivityService].
///
/// Exposes the current [isOnline] boolean state, a [stream] of updates, and updates
/// dynamically as the network state changes.
class ConnectivityNotifier extends Notifier<bool> {
  StreamSubscription<bool>? _subscription;

  @override
  bool build() {
    final service = ref.watch(connectivityServiceProvider);

    // Initial check
    service.isOnline.then((online) {
      if (state != online) {
        state = online;
      }
    });

    // Listen for updates
    _subscription?.cancel();
    _subscription = service.onConnectivityChanged.listen((online) {
      state = online;
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return true; // Default to online optimistically
  }

  /// Current online status
  bool get isOnline => state;

  /// Stream of status changes
  Stream<bool> get stream =>
      ref.read(connectivityServiceProvider).onConnectivityChanged;
}

/// Riverpod provider named `connectivityProvider` that exposes whether the device is online (`bool`),
/// while also exposing stream and current status via `ref.read(connectivityProvider.notifier)`.
///
/// Example:
/// ```dart
/// // In a ConsumerWidget:
/// final isOnline = ref.watch(connectivityProvider);
/// ```
final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, bool>(() {
  return ConnectivityNotifier();
});

/// Stream provider for listening directly to connectivity changes as an [AsyncValue<bool>].
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

