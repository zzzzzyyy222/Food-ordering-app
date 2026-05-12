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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: '',
    appId: '1:804297306047:web:d30821e3ff4c60fa443b0a',
    messagingSenderId: '804297306047',
    projectId: 'food-app-e99e1',
    authDomain: 'food-app-e99e1.firebaseapp.com',
    storageBucket: 'food-app-e99e1.firebasestorage.app',
    measurementId: 'G-6H16Q354VB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDyKhjRMkk3HMUVmnYC6W8bzp0jT7aJ0g',
    appId: '1:804297306047:android:9db56a162ded4287443b0a',
    messagingSenderId: '804297306047',
    projectId: 'food-app-e99e1',
    storageBucket: 'food-app-e99e1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDW6C3klCAb5IUR6S06VfjuPbk3VffSQKQ',
    appId: '1:804297306047:ios:63da19fd700dee50443b0a',
    messagingSenderId: '804297306047',
    projectId: 'food-app-e99e1',
    storageBucket: 'food-app-e99e1.firebasestorage.app',
    iosBundleId: 'com.example.foodApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDW6C3klCAb5IUR6S06VfjuPbk3VffSQKQ',
    appId: '1:804297306047:ios:63da19fd700dee50443b0a',
    messagingSenderId: '804297306047',
    projectId: 'food-app-e99e1',
    storageBucket: 'food-app-e99e1.firebasestorage.app',
    iosBundleId: 'com.example.foodApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDBt3nthomx6xGxDEWBOu_Y_cAv4oKcy3E',
    appId: '1:804297306047:web:9b3f735a1cc45d00443b0a',
    messagingSenderId: '804297306047',
    projectId: 'food-app-e99e1',
    authDomain: 'food-app-e99e1.firebaseapp.com',
    storageBucket: 'food-app-e99e1.firebasestorage.app',
    measurementId: 'G-Z9BRY54CKM',
  );

}
