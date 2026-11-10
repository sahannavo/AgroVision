import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/planner/presentation/day_plan_card.dart';
import 'package:app/features/planner/presentation/growth_stage_stepper.dart';
import 'package:app/features/planner/presentation/planner_empty_state.dart';
import 'package:app/features/planner/presentation/planner_screen.dart';
import 'package:app/features/planner/presentation/planner_summary_tiles.dart';
import 'package:app/features/planner/presentation/planner_ui_models.dart';
import 'package:app/features/planner/presentation/weather_strip.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: child,
    );
  }

  group('PlannerScreen Widget Tests', () {
    testWidgets('renders PlannerEmptyState when initialPlots is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PlannerScreen(initialPlots: []),
        ),
      );

      expect(find.byType(PlannerEmptyState), findsOneWidget);
      expect(find.text('No crop plots yet'), findsOneWidget);
      expect(find.text('Add crop plot'), findsOneWidget);
      expect(find.text('Precision schedules for your field'), findsOneWidget);
      expect(find.text('Maha Season'), findsOneWidget);
    });

    testWidgets('renders complete populated view when crop plots exist', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PlannerScreen(),
        ),
      );

      // Verify top app bar & offline header
      expect(find.text('AgroVision'), findsOneWidget);
      expect(find.text('Planner'), findsOneWidget);
      expect(find.text('Using weather saved 3 hours ago'), findsOneWidget);

      // Verify header and widgets
      expect(find.text('Crop Planner'), findsOneWidget);
      expect(find.byType(GrowthStageStepper), findsOneWidget);
      expect(find.byType(WeatherStrip), findsOneWidget);
      expect(find.byType(PlannerSummaryTiles), findsOneWidget);

      // Verify summary tiles
      expect(find.text('Water this week'), findsOneWidget);
      expect(find.text('Next fertilizer'), findsOneWidget);

      // Verify week plan and day cards
      expect(find.text("This week's plan"), findsOneWidget);
      expect(find.byType(DayPlanCard), findsNWidgets(7));

      // Verify specific cards from mockup
      expect(find.text('Monday, 12 Oct'), findsOneWidget);
      expect(find.text('Rain expected. Skip watering.'), findsOneWidget);
      expect(find.text('NPK 12–12–17 · 20 g / plant'), findsOneWidget);

      // Verify bottom automate card
      expect(find.text('Automate Next Week'), findsOneWidget);
      expect(find.text('Auto-fill'), findsOneWidget);
    });

    testWidgets('updates day selection when a day in weather strip is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PlannerScreen(),
        ),
      );

      expect(find.byType(WeatherStrip), findsOneWidget);

      // Tap on Monday in the weather strip
      await tester.tap(find.text('Mon'));
      await tester.pumpAndSettle();

      expect(find.text('Mon'), findsOneWidget);
    });

    testWidgets('switches selected crop plot using dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PlannerScreen(),
        ),
      );

      // Initially displays Tomato
      expect(find.text('Tomato'), findsWidgets);

      // Tap on dropdown to open menu
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();

      // Tap on Chilli option
      await tester.tap(find.text('Chilli').last);
      await tester.pumpAndSettle();

      expect(find.text('Chilli'), findsWidgets);
    });
  });

  group('DayPlanCard Widget Tests', () {
    testWidgets('renders regular watering card correctly', (WidgetTester tester) async {
      const plan = IrrigationDayPlan(
        id: 'test-1',
        dateLabel: 'Tuesday, 13 Oct',
        status: DayPlanStatus.done,
        waterAmount: '4 L/m²',
        scheduleTime: 'Morning (6:30 AM)',
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(body: DayPlanCard(plan: plan)),
        ),
      );

      expect(find.text('Tuesday, 13 Oct'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('4 L/m² drip irrigation · Morning (6:30 AM)'), findsOneWidget);
    });

    testWidgets('renders rain skipped card with note and stripe correctly', (WidgetTester tester) async {
      const plan = IrrigationDayPlan(
        id: 'test-2',
        dateLabel: 'Wednesday, 14 Oct',
        status: DayPlanStatus.skipped,
        waterAmount: '0 L/m²',
        scheduleTime: 'Skipped',
        isSkipped: true,
        skipReason: 'Rain expected. Skip watering.',
        skipDetail: 'Monsoon shower forecast (~18mm).',
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(body: DayPlanCard(plan: plan)),
        ),
      );

      expect(find.text('Wednesday, 14 Oct'), findsOneWidget);
      expect(find.text('Watering Skipped'), findsOneWidget);
      expect(find.text('Rain expected. Skip watering.'), findsOneWidget);
      expect(find.text('Monsoon shower forecast (~18mm).'), findsOneWidget);
    });
  });
}

