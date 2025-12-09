// Firebase configuration for Kardashev Ascension
// Generated from google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for each platform
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'run flutterfire configure to update this file.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'run flutterfire configure to update this file.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'run flutterfire configure to update this file.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // WEB CONFIGURATION
  // To enable web support, add a Web app in Firebase Console:
  // 1. Go to Firebase Console > Project Settings > Your Apps
  // 2. Click "Add app" > Web (</>)
  // 3. Register app and copy the config values here
  // ═══════════════════════════════════════════════════════════════
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSmL4V5FcL8BKgOs63jZn-LQMT051kTng',
    appId: '1:64394204725:web:PLACEHOLDER_WEB_APP_ID',
    messagingSenderId: '64394204725',
    projectId: 'rise-of-civilizations-80a7b',
    authDomain: 'rise-of-civilizations-80a7b.firebaseapp.com',
    storageBucket: 'rise-of-civilizations-80a7b.firebasestorage.app',
  );

  // ═══════════════════════════════════════════════════════════════
  // ANDROID CONFIGURATION
  // From google-services.json
  // ═══════════════════════════════════════════════════════════════
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSmL4V5FcL8BKgOs63jZn-LQMT051kTng',
    appId: '1:64394204725:android:6e06d3d3f1877970e6c37c',
    messagingSenderId: '64394204725',
    projectId: 'rise-of-civilizations-80a7b',
    storageBucket: 'rise-of-civilizations-80a7b.firebasestorage.app',
  );

  // ═══════════════════════════════════════════════════════════════
  // iOS CONFIGURATION
  // Add iOS app in Firebase Console to get these values
  // ═══════════════════════════════════════════════════════════════
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCSmL4V5FcL8BKgOs63jZn-LQMT051kTng',
    appId: '1:64394204725:ios:PLACEHOLDER_IOS_APP_ID',
    messagingSenderId: '64394204725',
    projectId: 'rise-of-civilizations-80a7b',
    storageBucket: 'rise-of-civilizations-80a7b.firebasestorage.app',
    iosBundleId: 'com.kardashev.kardashevAscension',
  );
}
