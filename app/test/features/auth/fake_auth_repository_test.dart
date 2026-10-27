import 'package:app/features/auth/data/fake_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeAuthRepository', () {
    late FakeAuthRepository authRepo;

    setUp(() {
      authRepo = FakeAuthRepository(delay: Duration.zero);
    });

    tearDown(() {
      authRepo.dispose();
    });

    test('initializes with sample user Nimal Perera signed in', () async {
      expect(authRepo.currentUser, isNotNull);
      expect(authRepo.currentUser?.fullName, equals('Nimal Perera'));
      expect(authRepo.currentUser?.email, equals('nimal.perera@agrovision.lk'));
      expect(authRepo.currentUser?.soilType, equals('Loam'));
      expect(authRepo.currentUser?.landSize, equals(2.5));

      final user = await authRepo.authStateChanges().first;
      expect(user?.fullName, equals('Nimal Perera'));
    });

    test('signIn updates currentUser and emits on stream', () async {
      final user = await authRepo.signIn(
        email: 'test@agrovision.lk',
        password: 'Password123',
      );
      expect(user.email, equals('test@agrovision.lk'));
      expect(authRepo.currentUser?.email, equals('test@agrovision.lk'));
    });

    test('register creates a new user profile', () async {
      final user = await authRepo.register(
        email: 'newfarmer@agrovision.lk',
        password: 'Password123',
        fullName: 'Sunil Silva',
        region: 'Matale',
        soilType: 'Clay',
        landSize: 3.0,
      );
      expect(user.fullName, equals('Sunil Silva'));
      expect(user.region, equals('Matale'));
      expect(authRepo.currentUser?.fullName, equals('Sunil Silva'));
    });

    test('signOut clears current user and emits null', () async {
      await authRepo.signOut();
      expect(authRepo.currentUser, isNull);
    });

    test('saveProfile updates profile data', () async {
      final current = authRepo.currentUser!;
      final updated = current.copyWith(fullName: 'Nimal P. Perera', landSize: 3.5);
      await authRepo.saveProfile(updated);
      expect(authRepo.currentUser?.fullName, equals('Nimal P. Perera'));
      expect(authRepo.currentUser?.landSize, equals(3.5));
    });
  });
}

