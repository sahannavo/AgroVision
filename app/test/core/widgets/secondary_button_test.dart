import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/secondary_button.dart';

Widget createTestableWidget(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(
        child: child,
      ),
    ),
  );
}

void main() {
  group('SecondaryButton Widget Tests', () {
    testWidgets('renders button label text', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          SecondaryButton(
            label: 'Scan another leaf',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Scan another leaf'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped in normal state',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestableWidget(
          SecondaryButton(
            label: 'Cancel',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(SecondaryButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not trigger onPressed when disabled (onPressed: null)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const SecondaryButton(
            label: 'Disabled Outline',
            onPressed: null,
          ),
        ),
      );

      final buttonFinder = find.byType(OutlinedButton);
      expect(buttonFinder, findsOneWidget);

      final outlinedButton = tester.widget<OutlinedButton>(buttonFinder);
      expect(outlinedButton.onPressed, isNull);
    });

    testWidgets('renders leading icon when provided',
        (WidgetTester tester) async {
      const iconKey = Key('secondary_icon');

      await tester.pumpWidget(
        createTestableWidget(
          SecondaryButton(
            label: 'Back',
            icon: const Icon(Icons.arrow_back, key: iconKey),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byKey(iconKey), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('shows loading spinner and ignores taps when isLoading is true',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestableWidget(
          SecondaryButton(
            label: 'Loading Action',
            isLoading: true,
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Action'), findsNothing);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('has default height of 52dp', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          SecondaryButton(
            label: 'Check Height',
            onPressed: () {},
          ),
        ),
      );

      final sizedBoxFinder = find.descendant(
        of: find.byType(SecondaryButton),
        matching: find.byType(SizedBox),
      ).first;

      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.height, equals(52.0));
    });
  });
}
