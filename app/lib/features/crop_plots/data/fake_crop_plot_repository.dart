import 'dart:async';
import '../domain/crop_plot.dart';
import '../domain/crop_plot_repository.dart';

/// Fake implementation of [CropPlotRepository] with sample data from design PNGs
/// (Tomato Thilina Bed #2, Green Chilli MICH 1 Bed #4, Brinjal Padagoda South Garden).
class FakeCropPlotRepository implements CropPlotRepository {
  FakeCropPlotRepository({
    this.delay = const Duration(milliseconds: 300),
  }) {
    _plots = List.of(_initialSamplePlots);
    _controller = StreamController<List<CropPlot>>.broadcast(
      onListen: () => _controller.add(List.unmodifiable(_plots)),
    );
  }

  final Duration delay;
  late final List<CropPlot> _plots;
  late final StreamController<List<CropPlot>> _controller;

  static List<CropPlot> get _initialSamplePlots {
    final now = DateTime.now();
    return [
      CropPlot(
        id: 'plot_tomato_01',
        userId: 'farmer_nimal_01',
        name: 'Tomato (Thilina)',
        cropType: 'Tomato',
        plantedDate: now.subtract(const Duration(days: 42)),
        soilType: 'Loam',
        growthStage: GrowthStage.flowering,
        areaSize: 1.0,
        location: 'Kurunegala North Field • Bed #2',
      ),
      CropPlot(
        id: 'plot_chilli_01',
        userId: 'farmer_nimal_01',
        name: 'Green Chilli (MICH 1)',
        cropType: 'Chilli',
        plantedDate: now.subtract(const Duration(days: 28)),
        soilType: 'Loam',
        growthStage: GrowthStage.vegetative,
        areaSize: 0.8,
        location: 'East Raised Terraces • Bed #4',
      ),
      CropPlot(
        id: 'plot_brinjal_01',
        userId: 'farmer_nimal_01',
        name: 'Brinjal (Padagoda)',
        cropType: 'Eggplant',
        plantedDate: now.subtract(const Duration(days: 60)),
        soilType: 'Loam',
        growthStage: GrowthStage.fruiting,
        areaSize: 0.7,
        location: 'South Garden Plot • 30 Plants',
      ),
    ];
  }

  @override
  Stream<List<CropPlot>> watchPlots({String? userId}) => _controller.stream;

  @override
  Future<List<CropPlot>> getPlots({String? userId}) async {
    await Future<void>.delayed(delay);
    return List.unmodifiable(_plots);
  }

  @override
  Future<CropPlot> addPlot(CropPlot plot) async {
    await Future<void>.delayed(delay);
    final newPlot = plot.id.isEmpty
        ? plot.copyWith(id: 'plot_${DateTime.now().millisecondsSinceEpoch}')
        : plot;
    _plots.add(newPlot);
    _controller.add(List.unmodifiable(_plots));
    return newPlot;
  }

  @override
  Future<void> updatePlot(CropPlot plot) async {
    await Future<void>.delayed(delay);
    final index = _plots.indexWhere((p) => p.id == plot.id);
    if (index != -1) {
      _plots[index] = plot;
      _controller.add(List.unmodifiable(_plots));
    }
  }

  @override
  Future<void> deletePlot(String plotId) async {
    await Future<void>.delayed(delay);
    _plots.removeWhere((p) => p.id == plotId);
    _controller.add(List.unmodifiable(_plots));
  }

  void dispose() {
    _controller.close();
  }
}
