import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_nATFwYcieUZAcdS9JyY1kctYwkpDbC0',
    appId: '1:5639673711:web:dummydummydummydummy', // Dummy web app ID to prevent crash
    messagingSenderId: '5639673711',
    projectId: 'shash-c7c31',
    authDomain: 'shash-c7c31.firebaseapp.com',
    storageBucket: 'shash-c7c31.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_nATFwYcieUZAcdS9JyY1kctYwkpDbC0',
    appId: '1:5639673711:android:8bbda000ed9aa36962ba9a',
    messagingSenderId: '5639673711',
    projectId: 'shash-c7c31',
    storageBucket: 'shash-c7c31.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_nATFwYcieUZAcdS9JyY1kctYwkpDbC0',
    appId: '1:5639673711:ios:dummydummydummydummy',
    messagingSenderId: '5639673711',
    projectId: 'shash-c7c31',
    storageBucket: 'shash-c7c31.firebasestorage.app',
    iosBundleId: 'shash.customer.app',
  );
}
