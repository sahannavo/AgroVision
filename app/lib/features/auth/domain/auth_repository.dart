import 'app_user.dart';

/// Contract for authentication operations in AgroVision.
abstract class AuthRepository {
  /// Stream that emits whenever the current user's sign-in state changes.
  Stream<AppUser?> authStateChanges();

  /// Gets the currently authenticated user, or null if signed out.
  AppUser? get currentUser;

  /// Authenticates using email and password.
  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  /// Registers a new user account with initial farm profile details.
  Future<AppUser> register({
    required String email,
    required String password,
    required String fullName,
    required String region,
    required String soilType,
    required double landSize,
    double? latitude,
    double? longitude,
  });

  /// Updates and saves the user profile.
  Future<void> saveProfile(AppUser user);

  /// Signs out the currently authenticated user.
  Future<void> signOut();
}
