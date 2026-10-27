import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'fake_auth_repository.dart';

/// Configuration flag to switch between fakes and Firebase implementations.
/// Default is true until phase 3 when Firebase Auth is integrated.
const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [AuthRepository] instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FakeAuthRepository();
});

/// StreamProvider exposing the current authentication state.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
});

