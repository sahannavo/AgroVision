import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/confidence_ring.dart';
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
  group('ConfidenceRing', () {
    testWidgets('displays percentage and caption correctly', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const ConfidenceRing(
            confidence: 0.92,
            caption: 'MATCH',
          ),
        ),
      );

      expect(find.text('92%'), findsOneWidget);
      expect(find.text('MATCH'), findsOneWidget);
    });

    testWidgets('supports percentage passed in 0-100 range', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const ConfidenceRing(
            confidence: 48.0,
            caption: 'MATCH',
          ),
        ),
      );

      expect(find.text('48%'), findsOneWidget);
      expect(find.text('MATCH'), findsOneWidget);
    });

    testWidgets('uses green color when confidence is at or above threshold', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const ConfidenceRing(
            confidence: 0.70,
            caption: 'MATCH',
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final animColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(animColor.value, AppColors.primaryGreen);
      expect(progressIndicator.value, 0.70);
    });

    testWidgets('uses warning/amber color when confidence is below 70%', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const ConfidenceRing(
            confidence: 0.48,
            caption: 'MATCH',
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final animColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(animColor.value, AppColors.warning);
      expect(progressIndicator.value, 0.48);
    });

    testWidgets('renders semantic label for accessibility', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const ConfidenceRing(
            confidence: 0.95,
            caption: 'MATCH',
          ),
        ),
      );

      final semanticsFinder = find.descendant(
        of: find.byType(ConfidenceRing),
        matching: find.byType(Semantics),
      );
      final semantics = tester.widget<Semantics>(semanticsFinder.first);
      expect(semantics.properties.label, '95 percent MATCH');
      expect(semantics.properties.value, '95%');
    });
  });
}
