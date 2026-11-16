import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'fake_auth_repository.dart';
import 'firebase_auth_repository.dart';

/// Set to false with `--dart-define=USE_FAKES=false` to use real Firebase.
/// Defaults to true so the front-end team can work without Firebase.
const bool kUseFakes =
    bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provides the correct [AuthRepository] implementation based on [kUseFakes].
///
/// - [kUseFakes] == true  → [FakeAuthRepository] (no Firebase required)
/// - [kUseFakes] == false → [FirebaseAuthRepository] (requires emulators or
///   a live Firebase project)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (kUseFakes) {
    return FakeAuthRepository();
  }
  return FirebaseAuthRepository();
});

/// StreamProvider exposing the current authentication state.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
});
