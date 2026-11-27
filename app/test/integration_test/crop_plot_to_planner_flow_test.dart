import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/crop_plots/data/fake_crop_plot_repository.dart';
import 'package:app/features/crop_plots/data/providers.dart';
import 'package:app/features/crop_plots/presentation/add_crop_plot_sheet.dart';
import 'package:app/features/planner/presentation/day_plan_card.dart';
import 'package:app/features/planner/presentation/planner_empty_state.dart';
import 'package:app/features/planner/presentation/planner_screen.dart';
import 'package:app/features/planner/presentation/planner_ui_models.dart';

void main() {
  group('Integration Flow: Add Crop Plot -> Planner', () {
    testWidgets(
        'Adding a crop plot from Planner empty state saves to repository and Planner renders schedule',
        (tester) async {
      final fakePlotRepo = FakeCropPlotRepository(delay: Duration.zero);
      final initialCount =
          (await tester.runAsync(() => fakePlotRepo.getPlots()))!.length;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cropPlotRepositoryProvider.overrideWithValue(fakePlotRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const PlannerScreen(initialPlots: []),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(PlannerEmptyState), findsOneWidget);

      final addPlotBtn = find.text('Add crop plot');
      await tester.ensureVisible(addPlotBtn);
      await tester.tap(addPlotBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AddCropPlotSheet), findsOneWidget);

      final savePlotBtn = find.text('Save plot');
      await tester.ensureVisible(savePlotBtn);
      await tester.tap(savePlotBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final updatedPlots =
          (await tester.runAsync(() => fakePlotRepo.getPlots()))!;
      expect(updatedPlots.length, initialCount + 1);

      // Verify PlannerScreen renders schedule when plots exist
      final latestPlot = updatedPlots.last;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cropPlotRepositoryProvider.overrideWithValue(fakePlotRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: PlannerScreen(
              key: const ValueKey('populated_planner'),
              initialPlots: [
                CropPlotItem(
                  id: latestPlot.id,
                  cropName: latestPlot.cropType,
                  plotName: latestPlot.name,
                  location: latestPlot.location,
                  season: 'Maha Season',
                  stage: CropGrowthStage.seedling,
                  stageDay: 1,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(PlannerEmptyState), findsNothing);
      expect(find.byType(DayPlanCard), findsWidgets);
    });
  });
}
