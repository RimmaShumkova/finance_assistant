import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase web options are not configured.');
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      _ => throw UnsupportedError(
          'Firebase options are configured only for Android.',
        ),
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvaSAF0RHv7RJYbJwMG1FIv6Rr4_3LecA',
    appId: '1:515949525417:android:99b34b2945a6ba716aecb8',
    messagingSenderId: '515949525417',
    projectId: 'frontass',
    storageBucket: 'frontass.firebasestorage.app',
  );
}
