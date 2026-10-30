import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/crop_plots/domain/crop_plot.dart';
import 'package:app/features/crop_plots/domain/crop_plot_repository.dart';
import 'package:app/features/crop_plots/presentation/add_crop_plot_sheet.dart';

class FakeCropPlotRepository {
  final List<CropPlot> plots = [];

  Future<void> add(CropPlot plot) async => plots.add(plot);
  Future<void> update(CropPlot plot) async {
    final idx = plots.indexWhere((p) => p.id == plot.id);
    if (idx != -1) plots[idx] = plot;
  }
}

void main() {
  group('AddCropPlotSheet Widget Tests', () {
    testWidgets('renders all form fields when opened in add mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cropPlotRepositoryProvider.overrideWithValue(FakeCropPlotRepository()),
          ],
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

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Title & Subtitle
      expect(find.text('Add crop plot'), findsOneWidget);
      expect(find.text('Maha Season 2024 · Kurunegala'), findsOneWidget);

      // Crop type chips
      expect(find.text('Crop type'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);
      expect(find.text('Chili'), findsOneWidget);
      expect(find.text('Eggplant'), findsOneWidget);

      // Planted date
      expect(find.text('Planted date'), findsOneWidget);

      // Growth stage
      expect(find.text('Growth stage'), findsOneWidget);
      expect(find.text('Seedling'), findsOneWidget);

      // Soil type & Area
      expect(find.text('Soil type'), findsOneWidget);
      expect(find.text('Area'), findsOneWidget);
      expect(find.text('acres'), findsOneWidget);

      // Action buttons
      expect(find.text('Save plot'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders in edit mode when existing plot is passed', (tester) async {
      final existingPlot = CropPlot(
        id: 'plot_test_1',
        cropType: 'Chili',
        plotName: 'Plot B',
        variety: 'MICH 1',
        plantedDate: DateTime(2024, 10, 20),
        growthStage: 'Vegetative',
        bed: 'East Terraces',
        soilType: 'Loam (Reddish Brown)',
        area: 0.8,
        areaUnit: 'acres',
        status: 'Active',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cropPlotRepositoryProvider.overrideWithValue(FakeCropPlotRepository()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showAddCropPlotSheet(context, plot: existingPlot),
                  child: const Text('Open Edit Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Edit Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Edit crop plot'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('0.8'), findsOneWidget);
    });
  });
}

