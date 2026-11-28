import 'package:app/app.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/core/router/route_names.dart';
import 'package:app/core/widgets/app_bottom_nav.dart';
import 'package:app/features/advisor/presentation/advisor_screen.dart';
import 'package:app/features/alerts/presentation/alerts_screen.dart';
import 'package:app/features/auth/presentation/login_screen.dart';
import 'package:app/features/auth/presentation/widgets/password_field.dart';
import 'package:app/features/crop_plots/presentation/add_crop_plot_sheet.dart';
import 'package:app/features/diagnosis/presentation/capture_screen.dart';
import 'package:app/features/diagnosis/presentation/result_screen.dart';
import 'package:app/features/history/presentation/history_screen.dart';
import 'package:app/features/home/presentation/home_screen.dart';
import 'package:app/features/planner/presentation/planner_screen.dart';
import 'package:app/features/profile/presentation/profile_screen.dart';
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
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();

    // If initial landing is on LoginScreen, log in using default sample credentials
    if (find.byType(LoginScreen).evaluate().isNotEmpty) {
      await tester.enterText(
        find.byType(TextFormField).first,
        'nimal.perera@agrovision.lk',
      );
      await tester.enterText(
        find.byType(PasswordField),
        'Password123',
      );
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
    }

    // Verify home route shows HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);

    // Verify bottom navigation items exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Scan crop disease'),
      findsOneWidget,
    );

    // Switch to Planner tab
    await tester.tap(find.text('Planner'));
    await tester.pumpAndSettle();
    expect(find.byType(PlannerScreen), findsOneWidget);

    // Switch to History tab
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);

    // Switch to Alerts tab
    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertsScreen), findsOneWidget);

    // Switch back to Home tab
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap Scan button to open /diagnose/capture
    await tester.tap(find.bySemanticsLabel('Scan crop disease'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(CaptureScreen), findsOneWidget);

    // Verify /diagnose/capture is displayed outside the bottom navigation shell
    expect(find.byType(AppBottomNav), findsNothing);

    // Verify /diagnose/capture is displayed outside the bottom navigation shell
    expect(find.byType(AppBottomNav), findsNothing);
  });

  testWidgets('showAddCropPlotSheet renders and closes properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAddCropPlotSheet(context),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Add crop plot'), findsOneWidget);
    expect(find.byType(AddCropPlotSheet), findsOneWidget);

    // Close sheet
    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();

    expect(find.text('Add crop plot'), findsNothing);
  });

  testWidgets('Standalone routes render correctly outside shell',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: AgroVisionApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Navigate to Advisor
    appRouter.go(AppRoutes.advisor);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AdvisorScreen), findsOneWidget);
    expect(find.byType(AppBottomNav), findsNothing);

    // Navigate to Profile
    appRouter.go(AppRoutes.profile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(AppBottomNav), findsNothing);

    // Navigate to Result
    appRouter.go(AppRoutes.diagnoseResult);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.byType(AppBottomNav), findsNothing);
  });
}
