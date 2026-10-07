import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Plataforma não suportada');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDq_GMcCXsvskqYgaAZ37BeezGV0KqiPyE',
    appId: '1:170411335258:web:e0586e0828cf1262d5ea85', // Verifique no painel do Firebase se o seu appId web é este mesmo
    messagingSenderId: '170411335258',
    projectId: 'controle-familiar-b9057',
    authDomain: 'controle-familiar-b9057.firebaseapp.com',
    storageBucket: 'controle-familiar-b9057.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDq_GMcCXsvskqYgaAZ37BeezGV0KqiPyE',
    appId: '1:170411335258:android:e0586e0828cf1262d5ea85',
    messagingSenderId: '170411335258',
    projectId: 'controle-familiar-b9057',
  );
}
