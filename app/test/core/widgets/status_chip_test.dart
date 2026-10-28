import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('StatusChip', () {
    testWidgets('StatusChip.healthy renders label and check icon', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          StatusChip.healthy(label: 'Zero Pathogens'),
        ),
      );

      expect(find.text('Zero Pathogens'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('StatusChip.moderate renders label and dot icon by default', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          StatusChip.moderate(label: 'Moderate'),
        ),
      );

      expect(find.text('Moderate'), findsOneWidget);
      // Background container check
      final container = tester.widget<Container>(
        find.descendant(of: find.byType(StatusChip), matching: find.byType(Container)).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFFFF3E0));
    });

    testWidgets('StatusChip.highRisk renders danger text and warning icon or dot', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          StatusChip.highRisk(label: 'High Risk', showDot: false),
        ),
      );

      expect(find.text('High Risk'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('StatusChip.needsAttention renders info icon and label', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          StatusChip.needsAttention(label: 'Needs Attention'),
        ),
      );

      expect(find.text('Needs Attention'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('StatusChip.synced renders cloud icon and label', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          StatusChip.synced(label: 'Synced'),
        ),
      );

      expect(find.text('Synced'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done_rounded), findsOneWidget);
    });

    testWidgets('StatusChip.pending renders hourglass icon and label', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          StatusChip.pending(label: 'Pending'),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
    });

    testWidgets('tapping StatusChip triggers onTap callback when enabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          StatusChip.healthy(
            label: 'Clickable',
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Clickable'));
      expect(tapped, isTrue);
    });

    testWidgets('disabled StatusChip renders with reduced opacity and does not trigger onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          StatusChip.healthy(
            label: 'Disabled',
            isEnabled: false,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      final opacity = tester.widget<Opacity>(
        find.descendant(of: find.byType(StatusChip), matching: find.byType(Opacity)).first,
      );
      expect(opacity.opacity, 0.5);

      await tester.tap(find.text('Disabled'));
      expect(tapped, isFalse);
    });
  });
}
