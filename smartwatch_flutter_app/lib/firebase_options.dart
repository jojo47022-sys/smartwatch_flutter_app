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
      case TargetPlatform.windows:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBFqb9i4cIBd_6FK1nwBpUE3nJZVWpD3Mw",
    authDomain: "smartwatch-669b1.firebaseapp.com",
    databaseURL: "https://smartwatch-669b1-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "smartwatch-669b1",
    storageBucket: "smartwatch-669b1.firebasestorage.app",
    messagingSenderId: "577984434584",
    appId: "1:577984434584:web:eaf91524d9641240c6dbed",
    measurementId: "G-WX9SCCYTKK"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFqb9i4cIBd_6FK1nwBpUE3nJZVWpD3Mw',
    appId: '1:577984434584:android:343fa4c210b39505c6dbed', 
    messagingSenderId: '577984434584',
    projectId: 'smartwatch-669b1',
    databaseURL: 'https://smartwatch-669b1-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'smartwatch-669b1.firebasestorage.app',
);
}