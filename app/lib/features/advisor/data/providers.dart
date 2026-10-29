import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/advisor_repository.dart';
import 'fake_advisor_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [AdvisorRepository] instance.
final advisorRepositoryProvider = Provider<AdvisorRepository>((ref) {
  return FakeAdvisorRepository();
});

