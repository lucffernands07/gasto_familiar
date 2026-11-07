import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Instância do GoogleSignIn configurada explicitamente com o Web Client ID e os scopes do Drive
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '170411335258-0oa5v413oh9e7ta7h8qu2lsane6h44eh.apps.googleusercontent.com' : null,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  // Obter o utilizador atual
  User? get currentUser => _auth.currentUser;

  // Stream para ouvir mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Função para fazer Login com a Conta do Google (Web + Mobile)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // --- FLUXO PARA NAVEGADOR (WEB / GITHUB PAGES) ---
        // Força a utilização do fluxo web integrado com o GoogleSignIn para respeitar o clientId e scopes do Drive
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
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
      rethrow;
    }
  }

  // Função para terminar sessão (Logout)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
