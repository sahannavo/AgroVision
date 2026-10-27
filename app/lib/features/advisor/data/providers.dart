import '../domain/advisor_repository.dart';
import 'fake_advisor_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

final _fakeAdvisorRepositoryInstance = FakeAdvisorRepository();

/// Provider for [AdvisorRepository].
AdvisorRepository get advisorRepositoryProvider => _fakeAdvisorRepositoryInstance;
