import 'package:app/app.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/core/router/route_names.dart';
import 'package:app/core/widgets/app_bottom_nav.dart';
import 'package:app/features/crop_plots/presentation/add_crop_plot_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AgroVisionApp shell and navigation test',
      (WidgetTester tester) async {
    // Set screen size within required 360-430 dp range
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: AgroVisionApp()));
    await tester.pumpAndSettle();

    // Verify initial route is /home and shows HomeScreen stub
    expect(find.text('HomeScreen'), findsOneWidget);
    expect(find.text('Route: /home'), findsOneWidget);

    // Verify bottom navigation items exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.byTooltip('Scan crop for diagnosis'), findsNothing);
    expect(
      find.bySemanticsLabel('Scan crop for diagnosis'),
      findsOneWidget,
    );

    // Switch to Planner tab
    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();
    expect(find.text('PlannerScreen'), findsOneWidget);
    expect(find.text('Route: /planner'), findsOneWidget);

    // Switch to History tab
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('HistoryScreen'), findsOneWidget);
    expect(find.text('Route: /history'), findsOneWidget);

    // Switch to Alerts tab
    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    expect(find.text('AlertsScreen'), findsOneWidget);
    expect(find.text('Route: /alerts'), findsOneWidget);

    // Switch back to Home tab
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('HomeScreen'), findsOneWidget);

    // Tap Scan button to open /diagnose/capture
    await tester.tap(find.bySemanticsLabel('Scan crop for diagnosis'));
    await tester.pumpAndSettle();
    expect(find.text('CaptureScreen'), findsOneWidget);
    expect(find.text('Route: /diagnose/capture'), findsOneWidget);

    // Verify /diagnose/capture is displayed outside the bottom navigation shell
    expect(find.byType(AppBottomNav), findsNothing);
  });

  testWidgets('showAddCropPlotSheet renders and closes properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAddCropPlotSheet(context),
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    );

    // Open sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Add Crop Plot'), findsOneWidget);
    expect(find.text('AddCropPlotSheet stub'), findsOneWidget);

    // Close sheet
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Add Crop Plot'), findsNothing);
  });

  testWidgets('Standalone routes render correctly outside shell',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: AgroVisionApp()));
    await tester.pumpAndSettle();

    // Navigate to Advisor
    appRouter.push(AppRoutes.advisor);
    await tester.pumpAndSettle();
    expect(find.text('AdvisorScreen'), findsOneWidget);
    expect(find.byType(AppBottomNav), findsNothing);

    // Navigate to Profile
    appRouter.push(AppRoutes.profile);
    await tester.pumpAndSettle();
    expect(find.text('ProfileScreen'), findsOneWidget);
    expect(find.byType(AppBottomNav), findsNothing);

    // Navigate to Result
    appRouter.push(AppRoutes.diagnoseResult);
    await tester.pumpAndSettle();
    expect(find.text('ResultScreen'), findsOneWidget);
    expect(find.byType(AppBottomNav), findsNothing);
  });
}
