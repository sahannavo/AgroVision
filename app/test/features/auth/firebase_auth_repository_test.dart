// ignore_for_file: avoid_print

/// Firebase Auth + Firestore emulator integration tests.
///
/// These tests require the Firebase Emulator Suite to be running:
///
///   firebase emulators:start --only auth,firestore
///
/// Then run:
///
///   cd app
///   flutter test test/features/auth/firebase_auth_repository_test.dart \
///     --dart-define=USE_EMULATORS=true \
///     --dart-define=USE_FAKES=false
///
/// The tests clear the emulator auth state between runs via the REST API so
/// they are fully independent.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:app/core/firebase/firebase_bootstrap.dart';
import 'package:app/features/auth/data/firebase_auth_repository.dart';
import 'package:app/features/auth/domain/app_user.dart';

// ── Emulator connection details ───────────────────────────────────────────

const _authEmulatorHost = 'localhost';
const _authEmulatorPort = 9099;
const _firestoreEmulatorHost = 'localhost';
const _firestoreEmulatorPort = 8080;
const _projectId = 'agrovision-dev';

// ── Test helpers ──────────────────────────────────────────────────────────

/// Clears all emulator users between tests via the Auth emulator REST API.
Future<void> _clearEmulatorUsers() async {
  final url = Uri.parse(
    'http://$_authEmulatorHost:$_authEmulatorPort'
    '/emulator/v1/projects/$_projectId/accounts',
  );
  await http.delete(url);
}

// ── Setup ─────────────────────────────────────────────────────────────────

late FirebaseAuthRepository _repo;

Future<void> _bootstrap() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'fake-api-key',
      appId: '1:000000000000:android:0000000000000000000000',
      messagingSenderId: '000000000000',
      projectId: _projectId,
      storageBucket: '$_projectId.appspot.com',
    ),
  );

  fb.FirebaseAuth.instance.useAuthEmulator(
    _authEmulatorHost,
    _authEmulatorPort,
  );
  FirebaseFirestore.instance.useFirestoreEmulator(
    _firestoreEmulatorHost,
    _firestoreEmulatorPort,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false, // disable for tests — no local cache
  );

  _repo = FirebaseAuthRepository(
    auth: fb.FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _bootstrap();
  });

  setUp(() async {
    // Clear emulator state before each test for isolation.
    await _clearEmulatorUsers();
    await fb.FirebaseAuth.instance.signOut().catchError((_) {});
  });

  // ── register ─────────────────────────────────────────────────────────────

  group('FirebaseAuthRepository.register', () {
    test('creates Firebase Auth user and Firestore profile document', () async {
      const email = 'nimal@agrovision-test.lk';
      const password = 'SecurePass1!';
      const fullName = 'Nimal Perera';
      const region = 'Kurunegala';
      const soilType = 'Loam';
      const landSize = 2.5;
      const latitude = 7.4863;
      const longitude = 80.3623;

      final AppUser user = await _repo.register(
        email: email,
        password: password,
        fullName: fullName,
        region: region,
        soilType: soilType,
        landSize: landSize,
        latitude: latitude,
        longitude: longitude,
      );

      // AppUser returned matches input
      expect(user.email, email);
      expect(user.fullName, fullName);
      expect(user.region, region);
      expect(user.soilType, soilType);
      expect(user.landSize, landSize);
      expect(user.latitude, latitude);
      expect(user.longitude, longitude);
      expect(user.uid, isNotEmpty);

      // Firestore document was created
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      expect(snap.exists, isTrue);
      expect(snap.data()!['email'], email);
      expect(snap.data()!['fullName'], fullName);
      expect(snap.data()!['region'], region);
      expect(snap.data()!['soilType'], soilType);
      expect(snap.data()!['landSize'], landSize);

      final GeoPoint? loc = snap.data()!['location'] as GeoPoint?;
      expect(loc, isNotNull);
      expect(loc!.latitude, closeTo(latitude, 0.0001));
      expect(loc.longitude, closeTo(longitude, 0.0001));
    });

    test('register trims whitespace from email', () async {
      final user = await _repo.register(
        email: '  trimmed@test.lk  ',
        password: 'Password1!',
        fullName: 'Test User',
        region: 'Colombo',
        soilType: 'Clay',
        landSize: 1.0,
      );
      expect(user.email, 'trimmed@test.lk');
    });
  });

  // ── signIn ───────────────────────────────────────────────────────────────

  group('FirebaseAuthRepository.signIn', () {
    setUp(() async {
      // Create a user to sign in with.
      await _repo.register(
        email: 'signin@agrovision-test.lk',
        password: 'CorrectPass1!',
        fullName: 'Sign In User',
        region: 'Kandy',
        soilType: 'Sandy',
        landSize: 1.0,
      );
      await _repo.signOut();
    });

    test('signs in with correct credentials and returns AppUser', () async {
      final user = await _repo.signIn(
        email: 'signin@agrovision-test.lk',
        password: 'CorrectPass1!',
      );
      expect(user.email, 'signin@agrovision-test.lk');
      expect(user.uid, isNotEmpty);
    });

    test('throws human-readable error on wrong password', () async {
      await expectLater(
        _repo.signIn(
          email: 'signin@agrovision-test.lk',
          password: 'WrongPass999!',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Incorrect email or password'),
          ),
        ),
      );
    });

    test('throws human-readable error for non-existent email', () async {
      await expectLater(
        _repo.signIn(
          email: 'nobody@agrovision-test.lk',
          password: 'AnyPass1!',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ── signOut ───────────────────────────────────────────────────────────────

  group('FirebaseAuthRepository.signOut', () {
    test('signs out successfully', () async {
      await _repo.register(
        email: 'signout@test.lk',
        password: 'Password1!',
        fullName: 'Sign Out User',
        region: 'Galle',
        soilType: 'Silt',
        landSize: 0.5,
      );
      expect(fb.FirebaseAuth.instance.currentUser, isNotNull);

      await _repo.signOut();
      expect(fb.FirebaseAuth.instance.currentUser, isNull);
    });
  });

  // ── saveProfile ───────────────────────────────────────────────────────────

  group('FirebaseAuthRepository.saveProfile', () {
    test('updates Firestore document fields', () async {
      final user = await _repo.register(
        email: 'profile@test.lk',
        password: 'Password1!',
        fullName: 'Original Name',
        region: 'Jaffna',
        soilType: 'Clay',
        landSize: 3.0,
      );

      final updated = user.copyWith(fullName: 'Updated Name', landSize: 5.0);
      await _repo.saveProfile(updated);

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      expect(snap.data()!['fullName'], 'Updated Name');
      expect(snap.data()!['landSize'], 5.0);
    });
  });
}
