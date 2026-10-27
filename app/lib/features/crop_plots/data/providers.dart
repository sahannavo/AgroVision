import '../domain/crop_plot_repository.dart';
import 'fake_crop_plot_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

final _fakeCropPlotRepositoryInstance = FakeCropPlotRepository();

/// Provider for [CropPlotRepository].
/// Screens watch and manage plots exclusively through this provider.
CropPlotRepository get cropPlotRepositoryProvider => _fakeCropPlotRepositoryInstance;
