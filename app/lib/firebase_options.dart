// GENERATED FILE — do not edit by hand.
//
// Run the following command to regenerate this file after creating the
// Firebase projects (see docs/FIREBASE_SETUP.md):
//
//   cd app
//   flutterfire configure --project=agrovision-dev --platforms=android,ios
//
// Until flutterfire configure has been run, this file contains placeholder
// values so the project compiles. Replace with the real values before any
// Firebase feature is exercised against a live project.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return android;
    }
  }

  // Replace these placeholder values with the output of `flutterfire configure`
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDn5UjGx_2rPm3lGWdgA15CIH-oA9_Yxws',
    appId: '1:483338217057:android:6420a89776e869f241ec20',
    messagingSenderId: '483338217057',
    projectId: 'agrovision-730c8',
    storageBucket: 'agrovision-730c8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'agrovision-dev',
    storageBucket: 'agrovision-dev.appspot.com',
    iosClientId: 'REPLACE_WITH_IOS_CLIENT_ID',
    iosBundleId: 'lk.nsbm.agrovision',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_MACOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'agrovision-dev',
    storageBucket: 'agrovision-dev.appspot.com',
    iosClientId: 'REPLACE_WITH_MACOS_CLIENT_ID',
    iosBundleId: 'lk.nsbm.agrovision',
  );
}
