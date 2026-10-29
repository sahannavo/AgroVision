import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/app_card.dart';

void main() {
  Widget buildTestCard({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? stripeColor,
    bool enabled = true,
    String? semanticLabel,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: AppCard(
            onTap: onTap,
            onLongPress: onLongPress,
            stripeColor: stripeColor,
            enabled: enabled,
            semanticLabel: semanticLabel,
            child: child,
          ),
        ),
      ),
    );
  }

  group('AppCard Widget Tests', () {
    testWidgets('renders child content with default styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestCard(
          child: const Text('Tomato Plot Card'),
        ),
      );

      expect(find.text('Tomato Plot Card'), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped and enabled', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestCard(
          onTap: () => tapped = true,
          child: const Text('Tappable Card'),
        ),
      );

      await tester.tap(find.text('Tappable Card'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not trigger onTap callback when enabled is false', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestCard(
          onTap: () => tapped = true,
          enabled: false,
          child: const Text('Disabled Card'),
        ),
      );

      await tester.tap(find.text('Disabled Card'));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('renders severity stripe when stripeColor is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestCard(
          stripeColor: AppColors.waterBlue,
          child: const Text('Irrigation Card'),
        ),
      );

      expect(find.text('Irrigation Card'), findsOneWidget);

      final decoratedBoxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final hasStripe = decoratedBoxes.any((box) {
        final decoration = box.decoration;
        return decoration is BoxDecoration && decoration.color == AppColors.waterBlue;
      });

      expect(hasStripe, isTrue);
    });

    testWidgets('applies semantic label when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestCard(
          semanticLabel: 'Crop status card',
          child: const Text('Content'),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == 'Crop status card',
        ),
        findsOneWidget,
      );
    });
  });
}
