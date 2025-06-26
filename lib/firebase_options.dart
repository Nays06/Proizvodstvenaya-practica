import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBpyx3OX_zucVIIOfCRZqMRFRe8YcjmCM8",
    authDomain: "project-610d6.firebaseapp.com",
    projectId: "project-610d6",
    storageBucket: "project-610d6.firebasestorage.app",
    messagingSenderId: "821565201289",
    appId: "1:821565201289:web:0112f6c4c5230497969f58",
    measurementId: "G-JDPNB60YMK"
  );
}