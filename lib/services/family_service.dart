import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> getActiveFamilyId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'familia_default';
    return user.uid;
  }

  // Preferências visuais salvas no SharedPreferences do dispositivo
  Future<String> getAppTitle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('custom_app_title') ?? 'Meus Gastos';
  }

  Future<void> setAppTitle(String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_app_title', title);
  }

  Future<String> getGreetingName() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('custom_greeting_name') ?? user?.displayName ?? 'Usuário';
  }

  Future<void> setGreetingName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_greeting_name', name);
  }

  // Métodos de Backup, Restauração e Zerar Banco
  Future<void> zerarBancoDados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final familyRef = _db.collection('families').doc(user.uid);
    final membersSnapshot = await familyRef.collection('members').get();
    for (var doc in membersSnapshot.docs) {
      await doc.reference.delete();
    }
    final transSnapshot = await familyRef.collection('transactions').get();
    for (var doc in transSnapshot.docs) {
      await doc.reference.delete();
    }
    await familyRef.delete();
  }
}
