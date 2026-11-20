import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/planner_repository.dart';
import 'fake_planner_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [PlannerRepository] instance.
final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return FakePlannerRepository();
});

