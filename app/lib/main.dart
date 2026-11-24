import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'features/auth/data/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase when not using fakes.
  // Run with --dart-define=USE_FAKES=false to enable Firebase.
  // Run with --dart-define=USE_EMULATORS=true to point at local emulators.
  if (!kUseFakes) {
    try {
      await firebaseBootstrap();
    } catch (e, st) {
      debugPrint('[Firebase] Bootstrap error: $e\n$st');
    }
  }

  runApp(const ProviderScope(child: AgroVisionApp()));
}
