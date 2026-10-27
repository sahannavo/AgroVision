import 'dart:async';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// Fake implementation of [AuthRepository] returning realistic sample data
/// matching the design PNGs (Nimal Perera, Kurunegala, 2.5 Acres).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    bool startSignedIn = true,
    this.delay = const Duration(milliseconds: 300),
  }) {
    _currentUser = startSignedIn ? sampleUser : null;
    _authStateController = StreamController<AppUser?>.broadcast(
      onListen: () => _authStateController.add(_currentUser),
    );
  }

  final Duration delay;
  late final StreamController<AppUser?> _authStateController;
  AppUser? _currentUser;

  /// Default sample user from design screens (Nimal Perera).
  static const AppUser sampleUser = AppUser(
    uid: 'farmer_nimal_01',
    email: 'nimal.perera@agrovision.lk',
    fullName: 'Nimal Perera',
    latitude: 7.4863,
    longitude: 80.3623,
    region: 'Kurunegala (Intermediate Lowland Region)',
    soilType: 'Loam',
    landSize: 2.5,
  );

  @override
  Stream<AppUser?> authStateChanges() => _authStateController.stream;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password must not be empty.');
    }
    _currentUser = sampleUser.copyWith(email: email.trim());
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String fullName,
    required String region,
    required String soilType,
    required double landSize,
    double? latitude,
    double? longitude,
  }) async {
    await Future<void>.delayed(delay);
    final newUser = AppUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      fullName: fullName.trim(),
      latitude: latitude ?? 7.4863,
      longitude: longitude ?? 80.3623,
      region: region,
      soilType: soilType,
      landSize: landSize,
    );
    _currentUser = newUser;
    _authStateController.add(_currentUser);
    return newUser;
  }

  @override
  Future<void> saveProfile(AppUser user) async {
    await Future<void>.delayed(delay);
    _currentUser = user;
    _authStateController.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(delay);
    _currentUser = null;
    _authStateController.add(null);
  }

  void dispose() {
    _authStateController.close();
  }
}
