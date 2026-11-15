import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/crop_plot_repository.dart';
import 'fake_crop_plot_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [CropPlotRepository] instance.
final cropPlotRepositoryProvider = Provider<CropPlotRepository>((ref) {
  return FakeCropPlotRepository();
});

