import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../weather/data/providers.dart';
import '../domain/advisor_repository.dart';
import 'fake_advisor_repository.dart';
import 'local_advisor_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [AdvisorRepository] instance.
///
/// Returns [FakeAdvisorRepository] when developing locally or running UI mock tests.
/// Switches to [LocalAdvisorRepository] when built with `--dart-define=USE_FAKES=false`.
final advisorRepositoryProvider = Provider<AdvisorRepository>((ref) {
  if (kUseFakes) {
    return FakeAdvisorRepository();
  }
  final weatherRepo = ref.watch(weatherRepositoryProvider);
  return LocalAdvisorRepository(weatherRepository: weatherRepo);
});
