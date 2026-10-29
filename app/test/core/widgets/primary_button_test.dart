import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/primary_button.dart';

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
  group('PrimaryButton Widget Tests', () {
    testWidgets('renders button label text', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          PrimaryButton(
            label: 'Log in',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped in normal state',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestableWidget(
          PrimaryButton(
            label: 'Submit',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not trigger onPressed when disabled (onPressed: null)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const PrimaryButton(
            label: 'Disabled Button',
            onPressed: null,
          ),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final elevatedButton = tester.widget<ElevatedButton>(buttonFinder);
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('renders leading icon when provided',
        (WidgetTester tester) async {
      const iconKey = Key('leading_icon');

      await tester.pumpWidget(
        createTestableWidget(
          PrimaryButton(
            label: 'Next',
            icon: const Icon(Icons.arrow_forward, key: iconKey),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byKey(iconKey), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('shows loading spinner and ignores taps when isLoading is true',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        createTestableWidget(
          PrimaryButton(
            label: 'Processing',
            isLoading: true,
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processing'), findsNothing);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('has default height of 52dp', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          PrimaryButton(
            label: 'Check Height',
            onPressed: () {},
          ),
        ),
      );

      final sizedBoxFinder = find.descendant(
        of: find.byType(PrimaryButton),
        matching: find.byType(SizedBox),
      ).first;

      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.height, equals(52.0));
    });
  });
}
