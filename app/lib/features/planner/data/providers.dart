import '../domain/planner_repository.dart';
import 'fake_planner_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

final _fakePlannerRepositoryInstance = FakePlannerRepository();

/// Provider for [PlannerRepository].
PlannerRepository get plannerRepositoryProvider => _fakePlannerRepositoryInstance;
