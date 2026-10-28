import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/services/connectivity_service.dart';

class FakeConnectivity implements Connectivity {
  List<ConnectivityResult> results = [ConnectivityResult.wifi];
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  void emit(List<ConnectivityResult> newResults) {
    results = newResults;
    _controller.add(newResults);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;
}

void main() {
  group('ConnectivityService', () {
    test('isOnlineFromResults returns true for wifi or mobile', () {
      expect(
        ConnectivityService.isOnlineFromResults([ConnectivityResult.wifi]),
        isTrue,
      );
      expect(
        ConnectivityService.isOnlineFromResults([ConnectivityResult.mobile]),
        isTrue,
      );
      expect(
        ConnectivityService.isOnlineFromResults([
          ConnectivityResult.wifi,
          ConnectivityResult.none,
        ]),
        isTrue,
      );
    });

    test('isOnlineFromResults returns false for none or empty list', () {
      expect(
        ConnectivityService.isOnlineFromResults([ConnectivityResult.none]),
        isFalse,
      );
      expect(
        ConnectivityService.isOnlineFromResults([]),
        isFalse,
      );
    });

    test('isOnline checks connectivity correctly', () async {
      final fake = FakeConnectivity();
      fake.results = [ConnectivityResult.mobile];
      final service = ConnectivityService(connectivity: fake);

      expect(await service.isOnline, isTrue);

      fake.results = [ConnectivityResult.none];
      expect(await service.isOnline, isFalse);
    });

    test('onConnectivityChanged emits status stream', () async {
      final fake = FakeConnectivity();
      final service = ConnectivityService(connectivity: fake);

      final expectations = expectLater(
        service.onConnectivityChanged,
        emitsInOrder([false, true]),
      );

      fake.emit([ConnectivityResult.none]);
      fake.emit([ConnectivityResult.wifi]);

      await expectations;
    });
  });

  group('connectivityProvider', () {
    test('notifies listeners when network status changes', () async {
      final fake = FakeConnectivity();
      fake.results = [ConnectivityResult.wifi];
      final service = ConnectivityService(connectivity: fake);

      final container = ProviderContainer(
        overrides: [
          connectivityServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      // Initially true (default optimistic)
      expect(container.read(connectivityProvider), isTrue);

      // Emit offline
      fake.emit([ConnectivityResult.none]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(container.read(connectivityProvider), isFalse);
      expect(container.read(connectivityProvider.notifier).isOnline, isFalse);

      // Emit online again
      fake.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(container.read(connectivityProvider), isTrue);
    });
  });
}

