import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/crop_plot_repository.dart';
import 'fake_crop_plot_repository.dart';
import 'firebase_crop_plot_repository.dart';

/// Set to false with `--dart-define=USE_FAKES=false` to use real Firebase.
/// Defaults to true so the front-end team can work without Firebase.
const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [CropPlotRepository] instance.
final cropPlotRepositoryProvider = Provider<CropPlotRepository>((ref) {
  if (kUseFakes) {
    return FakeCropPlotRepository();
  }
  return FirebaseCropPlotRepository();
});
