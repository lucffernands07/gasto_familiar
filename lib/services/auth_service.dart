import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Obter o utilizador atual
  User? get currentUser => _auth.currentUser;

  // Stream para ouvir mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Função para fazer Login com a Conta do Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Inicia o fluxo de autenticação do Google no dispositivo
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Utilizador cancelou o login

      // Obtém os detalhes de autenticação do pedido
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Cria uma nova credencial para o Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Faz login no Firebase com a credencial do Google
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Erro ao fazer login com o Google: $e');
      return null;
    }
  }

  // Função para terminar sessão (Logout)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
