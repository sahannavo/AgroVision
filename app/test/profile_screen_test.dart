import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/profile/presentation/profile_screen.dart';
import 'package:app/features/crop_plots/domain/crop_plot.dart';
import 'package:app/features/crop_plots/domain/crop_plot_repository.dart';

// Fake CropPlotRepository for testing
class FakeCropPlotRepository {
  final List<CropPlot> plots = [
    CropPlot(
      id: 'plot_1',
      cropType: 'Tomato',
      plotName: 'Plot A',
      variety: 'Thilina var.',
      plantedDate: DateTime(2024, 10, 12),
      growthStage: 'Flowering',
      bed: 'Bed #2',
      soilType: 'Loam (Reddish Brown)',
      area: 1.0,
      areaUnit: 'acre',
      status: 'Active',
    ),
    CropPlot(
      id: 'plot_2',
      cropType: 'Green Chilli',
      plotName: 'Plot B',
      variety: 'MICH 1',
      plantedDate: DateTime(2024, 10, 28),
      growthStage: 'Vegetative',
      bed: 'East Terraces',
      soilType: 'Loam (Reddish Brown)',
      area: 0.8,
      areaUnit: 'acre',
      status: 'Active',
    ),
    CropPlot(
      id: 'plot_3',
      cropType: 'Brinjal',
      plotName: 'Plot C',
      variety: 'Padagoda',
      plantedDate: DateTime(2024, 9, 15),
      growthStage: 'Fruiting',
      bed: 'South Garden',
      soilType: 'Loam (Reddish Brown)',
      area: 0.7,
      areaUnit: 'acre',
      status: 'Active',
    ),
  ];

  Future<List<CropPlot>> getAll() async => plots;
  Stream<List<CropPlot>> watchAll() => Stream.value(plots);
  Future<void> add(CropPlot plot) async => plots.add(plot);
  Future<void> update(CropPlot plot) async {
    final idx = plots.indexWhere((p) => p.id == plot.id);
    if (idx != -1) plots[idx] = plot;
  }
}

void main() {
  group('ProfileScreen Widget Tests', () {
    testWidgets('renders all main profile sections with sample content', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cropPlotRepositoryProvider.overrideWithValue(FakeCropPlotRepository()),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top bar
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Offline mode'), findsOneWidget);

      // Header card
      expect(find.text('Nimal Perera'), findsOneWidget);
      expect(find.text('nimal.kurunegala@agrovision.lk'), findsOneWidget);
      expect(find.text('Nightshade Specialist'), findsOneWidget);
      expect(find.text("Maha '24"), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      // Farm Info Card
      expect(find.text('My farm'), findsOneWidget);
      expect(find.text('Kurunegala District'), findsOneWidget);
      expect(find.text('Kurunegala'), findsOneWidget);
      expect(find.text('NW Province'), findsOneWidget);
      expect(find.text('Loam (Reddish Brown)'), findsOneWidget);
      expect(find.text('2.5 acres'), findsOneWidget);

      // Crop plots section
      expect(find.text('My crop plots'), findsOneWidget);
      expect(find.text('3 Active'), findsOneWidget);
      expect(find.text('Season Maha 2024'), findsOneWidget);
      expect(find.text('Add crop plot'), findsOneWidget);

      // Plots content
      expect(find.textContaining('Tomato · Plot A'), findsOneWidget);
      expect(find.textContaining('Green Chilli · Plot B'), findsOneWidget);
      expect(find.textContaining('Brinjal · Plot C'), findsOneWidget);

      // Settings section
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Offline data'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);

      // Log out button
      expect(find.text('Log out'), findsOneWidget);

      // Footer
      expect(
        find.text('AgroVision v2.4 (Maha Edition) · DOA Peradeniya Guidelines'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Add crop plot button opens the sheet', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cropPlotRepositoryProvider.overrideWithValue(FakeCropPlotRepository()),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final addButton = find.text('Add crop plot');
      expect(addButton, findsOneWidget);
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet title and fields appear
      expect(find.text('Maha Season 2024 · Kurunegala'), findsOneWidget);
      expect(find.text('Crop type'), findsOneWidget);
      expect(find.text('Tomato'), findsWidgets);
      expect(find.text('Save plot'), findsOneWidget);
    });
  });
}

