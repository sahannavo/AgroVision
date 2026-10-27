import 'package:app/features/crop_plots/data/fake_crop_plot_repository.dart';
import 'package:app/features/crop_plots/domain/crop_plot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeCropPlotRepository', () {
    late FakeCropPlotRepository repo;

    setUp(() {
      repo = FakeCropPlotRepository(delay: Duration.zero);
    });

    tearDown(() {
      repo.dispose();
    });

    test('initializes with 3 sample nightshade plots from designs', () async {
      final plots = await repo.getPlots();
      expect(plots.length, equals(3));

      final tomato = plots.firstWhere((p) => p.cropType == 'Tomato');
      expect(tomato.name, equals('Tomato (Thilina)'));
      expect(tomato.growthStage, equals(GrowthStage.flowering));
      expect(tomato.location, contains('Bed #2'));

      final chilli = plots.firstWhere((p) => p.cropType == 'Chilli');
      expect(chilli.growthStage, equals(GrowthStage.vegetative));

      final brinjal = plots.firstWhere((p) => p.cropType == 'Eggplant');
      expect(brinjal.growthStage, equals(GrowthStage.fruiting));
    });

    test('addPlot appends plot and emits on watch stream', () async {
      final initialPlots = await repo.getPlots();
      final newPlot = CropPlot(
        id: 'plot_potato_01',
        userId: 'farmer_nimal_01',
        name: 'Potato (Granola)',
        cropType: 'Potato',
        plantedDate: DateTime.now().subtract(const Duration(days: 14)),
        soilType: 'Loam',
        growthStage: GrowthStage.seedling,
        areaSize: 0.5,
        location: 'Upper Terraces',
      );

      await repo.addPlot(newPlot);
      final updatedPlots = await repo.getPlots();
      expect(updatedPlots.length, equals(initialPlots.length + 1));
      expect(updatedPlots.last.name, equals('Potato (Granola)'));
    });

    test('updatePlot updates existing plot', () async {
      final plots = await repo.getPlots();
      final target = plots.first;
      final updated = target.copyWith(growthStage: GrowthStage.fruiting);

      await repo.updatePlot(updated);
      final currentPlots = await repo.getPlots();
      expect(currentPlots.first.growthStage, equals(GrowthStage.fruiting));
    });

    test('deletePlot removes plot from list', () async {
      final plots = await repo.getPlots();
      final targetId = plots.first.id;

      await repo.deletePlot(targetId);
      final currentPlots = await repo.getPlots();
      expect(currentPlots.any((p) => p.id == targetId), isFalse);
    });
  });
}

