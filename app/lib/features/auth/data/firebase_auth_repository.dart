import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
///
/// On [register] it:
///  1. Creates a Firebase Auth user (email + password).
///  2. Writes the users/{uid} Firestore document with all profile fields.
///
/// On [signIn] it authenticates with Firebase Auth and reads the matching
/// Firestore document to build the full [AppUser].
///
/// On [saveProfile] it updates the Firestore document for the current user.
///
/// Never import this file from presentation code — use [authRepositoryProvider].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // ── Collection reference ─────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ── AuthRepository interface ─────────────────────────────────────────────

  @override
  AppUser? get currentUser {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    // We don't have the full profile here; callers should use authStateChanges.
    return _minimalUser(fbUser);
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return (await _fetchProfile(fbUser.uid)) ?? _minimalUser(fbUser);
    });
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final profile = await _fetchProfile(uid);
      return profile ?? _minimalUser(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    }
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
    try {
      // 1. Create the Auth user.
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;

      // 2. Build the Firestore document.
      final GeoPoint? location = (latitude != null && longitude != null)
          ? GeoPoint(latitude, longitude)
          : null;

      final doc = <String, dynamic>{
        'uid': uid,
        'email': email.trim(),
        'fullName': fullName.trim(),
        'region': region,
        'soilType': soilType,
        'landSize': landSize,
        'createdAt': FieldValue.serverTimestamp(),
        'location': location,
      };

      await _users.doc(uid).set(doc);

      return AppUser(
        uid: uid,
        email: email.trim(),
        fullName: fullName.trim(),
        region: region,
        soilType: soilType,
        landSize: landSize,
        latitude: latitude,
        longitude: longitude,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    }
  }

  @override
  Future<void> saveProfile(AppUser user) async {
    final GeoPoint? location =
        (user.latitude != null && user.longitude != null)
            ? GeoPoint(user.latitude!, user.longitude!)
            : null;

    final updates = <String, dynamic>{
      'fullName': user.fullName,
      'region': user.region,
      'soilType': user.soilType,
      'landSize': user.landSize,
      'location': location,
    };

    await _users.doc(user.uid).update(updates);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Fetches the full user profile from Firestore.
  /// Returns null when the document does not yet exist.
  Future<AppUser?> _fetchProfile(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    final GeoPoint? loc = data['location'] as GeoPoint?;
    return AppUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      region: data['region'] as String? ?? '',
      soilType: data['soilType'] as String? ?? '',
      landSize: (data['landSize'] as num?)?.toDouble() ?? 0.0,
      latitude: loc?.latitude,
      longitude: loc?.longitude,
    );
  }

  /// Creates a minimal [AppUser] from a Firebase Auth user (no Firestore data).
  AppUser _minimalUser(fb.User fbUser) => AppUser(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        fullName: fbUser.displayName ?? '',
        region: '',
        soilType: '',
        landSize: 0.0,
      );

  /// Translates [fb.FirebaseAuthException] codes into human-readable messages.
  Exception _translateAuthError(fb.FirebaseAuthException e) {
    final message = switch (e.code) {
      'wrong-password' || 'invalid-credential' =>
        'Incorrect email or password. Please try again.',
      'email-already-in-use' =>
        'An account with this email already exists. Try logging in.',
      'user-not-found' =>
        'No account found for this email. Please register.',
      'network-request-failed' =>
        'No internet connection. Please check your network and try again.',
      'too-many-requests' =>
        'Too many failed attempts. Please wait a moment and try again.',
      'weak-password' =>
        'Password is too weak. Use at least 8 characters.',
      'invalid-email' =>
        'The email address is not valid.',
      _ => 'Authentication error: ${e.message ?? e.code}',
    };
    return Exception(message);
  }
}
