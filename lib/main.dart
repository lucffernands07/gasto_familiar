import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  // Garante que os bindings do Flutter estejam prontos antes de chamar o Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase
  await Firebase.initializeApp();
  
  runApp(const GastoFamiliarApp());
}

class GastoFamiliarApp extends StatelessWidget {
  const GastoFamiliarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gasto Familiar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFAF6EE),
        useMaterial3: true,
      ),
      // O StreamBuilder escuta se o usuário está logado no Firebase ou não
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto verifica o estado do login, exibe uma tela de carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFFB7B2)),
              ),
            );
          }

          // Se tiver um usuário autenticado, abre a HomeScreen
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }

          // Se não estiver logado, exibe a tela de Login
          return const LoginScreen();
        },
      ),
    );
  }
}
