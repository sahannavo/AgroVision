import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/services/connectivity_service.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/offline_banner.dart';

class MockOfflineConnectivityNotifier extends ConnectivityNotifier {
  @override
  bool build() => false;
}

class MockOnlineConnectivityNotifier extends ConnectivityNotifier {
  @override
  bool build() => true;
}

void main() {
  Widget buildThemedWidget({
    required Widget child,
    List<dynamic> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: child,
          ),
        ),
      ),
    );
  }

  group('OfflinePill', () {
    testWidgets('renders default label and cloud icon', (tester) async {
      await tester.pumpWidget(
        buildThemedWidget(
          child: const OfflinePill(),
        ),
      );

      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('renders custom label correctly', (tester) async {
      await tester.pumpWidget(
        buildThemedWidget(
          child: const OfflinePill(label: 'No Signal'),
        ),
      );

      expect(find.text('No Signal'), findsOneWidget);
    });

    testWidgets('has accessible semantics', (tester) async {
      await tester.pumpWidget(
        buildThemedWidget(
          child: const OfflinePill(),
        ),
      );

      expect(
        find.bySemanticsLabel('Network status: Offline'),
        findsOneWidget,
      );
    });

    testWidgets('supports disabled state', (tester) async {
      await tester.pumpWidget(
        buildThemedWidget(
          child: const OfflinePill(enabled: false),
        ),
      );

      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });
  });

  group('OfflineBanner', () {
    testWidgets('renders message and cloud icon', (tester) async {
      const message = 'Offline. Showing weather saved 2 hours ago.';
      await tester.pumpWidget(
        buildThemedWidget(
          child: const OfflineBanner(message: message),
        ),
      );

      expect(find.text(message), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        buildThemedWidget(
          child: const OfflineBanner(
            trailing: Text('Retry'),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('has accessible semantics', (tester) async {
      const message = 'Custom offline text';
      await tester.pumpWidget(
        buildThemedWidget(
          child: const OfflineBanner(message: message),
        ),
      );

      expect(
        find.bySemanticsLabel('Offline banner: $message'),
        findsOneWidget,
      );
    });
  });

  group('OfflineBanner.auto', () {
    testWidgets('is hidden when online', (tester) async {
      const message = 'Offline. Showing cached data.';
      await tester.pumpWidget(
        buildThemedWidget(
          overrides: [
            connectivityProvider.overrideWith(
              () => MockOnlineConnectivityNotifier(),
            ),
          ],
          child: const OfflineBanner.auto(message: message),
        ),
      );
      await tester.pump();

      expect(find.text(message), findsNothing);
      expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    });

    testWidgets('is visible when offline', (tester) async {
      const message = 'Offline. Showing cached data.';
      await tester.pumpWidget(
        buildThemedWidget(
          overrides: [
            connectivityProvider.overrideWith(
              () => MockOfflineConnectivityNotifier(),
            ),
          ],
          child: const OfflineBanner.auto(message: message),
        ),
      );
      await tester.pump();

      expect(find.text(message), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });
  });
}
