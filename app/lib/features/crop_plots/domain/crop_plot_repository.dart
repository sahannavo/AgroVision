import 'crop_plot.dart';

/// Contract for managing crop plots in AgroVision.
abstract class CropPlotRepository {
  /// Watches the list of crop plots belonging to the user.
  Stream<List<CropPlot>> watchPlots({String? userId});

  /// Gets the list of crop plots belonging to the user.
  Future<List<CropPlot>> getPlots({String? userId});

  /// Adds a new crop plot.
  Future<CropPlot> addPlot(CropPlot plot);

  /// Updates an existing crop plot.
  Future<void> updatePlot(CropPlot plot);

  /// Deletes a crop plot by its ID.
  Future<void> deletePlot(String plotId);
}
