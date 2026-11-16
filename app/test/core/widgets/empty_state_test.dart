import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/empty_state.dart';

void main() {
  Widget buildTestEmptyState({
    Widget illustration = const Icon(Icons.eco_outlined, size: 48),
    required String title,
    required String message,
    String? buttonLabel,
    IconData? buttonIcon,
    VoidCallback? onButtonPressed,
    Widget? extraContent,
    bool buttonEnabled = true,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: EmptyState(
            illustration: illustration,
            title: title,
            message: message,
            buttonLabel: buttonLabel,
            buttonIcon: buttonIcon,
            onButtonPressed: onButtonPressed,
            extraContent: extraContent,
            buttonEnabled: buttonEnabled,
          ),
        ),
      ),
    );
  }

  group('EmptyState Widget Tests', () {
    testWidgets('renders illustration, title, and message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestEmptyState(
          title: 'No crop plots yet',
          message: 'Add a plot to get a tailored watering and fertilizer schedule.',
        ),
      );

      expect(find.byIcon(Icons.eco_outlined), findsOneWidget);
      expect(find.text('No crop plots yet'), findsOneWidget);
      expect(
        find.text('Add a plot to get a tailored watering and fertilizer schedule.'),
        findsOneWidget,
      );
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders primary action button and handles tap', (WidgetTester tester) async {
      var buttonTapped = false;

      await tester.pumpWidget(
        buildTestEmptyState(
          title: 'No crop plots yet',
          message: 'Add a plot to start planning.',
          buttonLabel: 'Add crop plot',
          buttonIcon: Icons.add_circle_outline,
          onButtonPressed: () => buttonTapped = true,
        ),
      );

      expect(find.text('Add crop plot'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(buttonTapped, isTrue);
    });

    testWidgets('does not trigger onButtonPressed when buttonEnabled is false', (WidgetTester tester) async {
      var buttonTapped = false;

      await tester.pumpWidget(
        buildTestEmptyState(
          title: 'Empty List',
          message: 'Nothing here.',
          buttonLabel: 'Disabled Action',
          buttonEnabled: false,
          onButtonPressed: () => buttonTapped = true,
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(buttonTapped, isFalse);
    });

    testWidgets('renders extraContent slot when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestEmptyState(
          title: 'No crops',
          message: 'Select a crop below',
          extraContent: const Text('Tomato • Chilli • Brinjal'),
        ),
      );

      expect(find.text('Tomato • Chilli • Brinjal'), findsOneWidget);
    });
  });
}
