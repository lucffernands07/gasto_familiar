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

  // Preencha com as credenciais do seu Firebase Console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SUA_API_KEY_WEB',
    appId: '1:170411335258:web:SUA_APP_ID_WEB',
    messagingSenderId: '170411335258',
    projectId: 'controle-familiar-b9057',
    authDomain: 'controle-familiar-b9057.firebaseapp.com',
    storageBucket: 'controle-familiar-b9057.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUA_API_KEY_ANDROID',
    appId: '1:170411335258:android:SUA_APP_ID_ANDROID',
    messagingSenderId: '170411335258',
    projectId: 'controle-familiar-b9057',
  );
}
