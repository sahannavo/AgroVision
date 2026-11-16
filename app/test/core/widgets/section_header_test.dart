import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/section_header.dart';

void main() {
  Widget buildTestSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onActionTap,
    Widget? trailing,
    String? actionSemanticLabel,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SectionHeader(
            title: title,
            actionLabel: actionLabel,
            onActionTap: onActionTap,
            trailing: trailing,
            actionSemanticLabel: actionSemanticLabel,
          ),
        ),
      ),
    );
  }

  group('SectionHeader Widget Tests', () {
    testWidgets('renders title text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestSectionHeader(title: "This week's plan"),
      );

      expect(find.text("This week's plan"), findsOneWidget);
      expect(find.byType(SectionHeader), findsOneWidget);
    });

    testWidgets('renders action label and triggers onActionTap on press', (WidgetTester tester) async {
      var actionTriggered = false;

      await tester.pumpWidget(
        buildTestSectionHeader(
          title: 'Crop Profiles',
          actionLabel: 'View all',
          onActionTap: () => actionTriggered = true,
        ),
      );

      expect(find.text('View all'), findsOneWidget);

      await tester.tap(find.text('View all'));
      await tester.pumpAndSettle();

      expect(actionTriggered, isTrue);
    });

    testWidgets('renders custom trailing widget when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestSectionHeader(
          title: 'Upcoming Irrigation',
          trailing: const Chip(label: Text('7 ACTIONS')),
        ),
      );

      expect(find.text('7 ACTIONS'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('provides semantics for action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestSectionHeader(
          title: 'Settings',
          actionLabel: 'Manage',
          actionSemanticLabel: 'Manage farm settings',
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == 'Manage farm settings',
        ),
        findsOneWidget,
      );
    });
  });
}
