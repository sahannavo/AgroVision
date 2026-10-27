import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'fake_auth_repository.dart';

/// Configuration flag to switch between fakes and Firebase implementations.
/// Default is true until phase 3 when Firebase Auth is integrated.
const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Global fake instance preserving auth state changes during runtime.
final _fakeAuthRepositoryInstance = FakeAuthRepository();

/// Provider for [AuthRepository].
/// When flutter_riverpod is merged into pubspec.yaml by SDL, this will be:
/// `final authRepositoryProvider = Provider<AuthRepository>((ref) => ...);`
AuthRepository get authRepositoryProvider => _fakeAuthRepositoryInstance;

/// Stream provider for user authentication state changes.
/// When flutter_riverpod is merged into pubspec.yaml by SDL, this will be:
/// `final authStateProvider = StreamProvider<AppUser?>((ref) => ref.watch(authRepositoryProvider).authStateChanges());`
Stream<AppUser?> get authStateProvider => authRepositoryProvider.authStateChanges();
