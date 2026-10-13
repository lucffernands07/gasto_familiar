import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Obter o utilizador atual
  User? get currentUser => _auth.currentUser;

  // Stream para ouvir mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Função para fazer Login com a Conta do Google (Web + Mobile)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // --- FLUXO PARA NAVEGADOR (WEB / GITHUB PAGES) ---
        // Usa o pop-up nativo do Firebase para Web
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // --- FLUXO PARA APLICATIVO NATIVO (ANDROID / IOS) ---
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // Usuário cancelou

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('Erro ao fazer login com o Google: $e');
      rethrow; // Repassa o erro para a tela exibir na SnackBar se necessário
    }
  }

  // Função para terminar sessão (Logout)
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
