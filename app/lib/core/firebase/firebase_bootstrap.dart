import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Whether the app should connect to Firebase Emulator Suite.
///
/// Pass `--dart-define=USE_EMULATORS=true` to flutter run / flutter test.
const bool kUseEmulators =
    bool.fromEnvironment('USE_EMULATORS', defaultValue: false);

/// Initialises Firebase and, when [kUseEmulators] is true, points every
/// Firebase service at the local emulators running on localhost.
///
/// Call this once from [main] before [runApp]:
/// ```dart
/// await firebaseBootstrap();
/// ```
Future<void> firebaseBootstrap() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ── Offline persistence for Firestore ────────────────────────────────────
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    if (kUseEmulators) {
      _connectToEmulators();
    }
  } catch (e, st) {
    debugPrint('[Firebase] Bootstrap initialization failed: $e\n$st');
  }
}

/// Points all Firebase services at the local emulator ports defined in
/// firebase.json. Called only when USE_EMULATORS=true.
void _connectToEmulators() {
  const String host = 'localhost';

  // On Android emulators the loopback address differs from iOS/desktop.
  // Using 'localhost' works for both iOS simulator and Android emulator
  // when the Firebase SDK resolves it, but on Android you can also use
  // '10.0.2.2' if you experience connection issues.

  if (kDebugMode) {
    debugPrint('[Firebase] Connecting to emulators on $host');
  }

  FirebaseAuth.instance.useAuthEmulator(host, 9099);

  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

  FirebaseStorage.instance.useStorageEmulator(host, 9199);

  FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
}
