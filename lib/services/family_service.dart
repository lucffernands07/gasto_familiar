import 'dart:convert';
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
    final historySnapshot = await familyRef.collection('history').get();
    for (var doc in historySnapshot.docs) {
      await doc.reference.delete();
    }
    await familyRef.delete();
  }

  Future<String> fazerBackup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilizador não autenticado.');

    final familyId = user.uid;
    final familyDoc = await _db.collection('families').doc(familyId).get();
    final membersSnapshot = await _db.collection('families').doc(familyId).collection('members').get();
    final transactionsSnapshot = await _db.collection('families').doc(familyId).collection('transactions').get();

    // Mapeamento limpo e seguro para evitar erros de minificação na Web
    final Map<String, dynamic> backupData = {
      'familyInfo': familyDoc.exists && familyDoc.data() != null ? Map<String, dynamic>.from(familyDoc.data()!) : {},
      'members': membersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nome': data['nome'] ?? '',
          'saldo': (data['saldo'] ?? 0.0).toDouble(),
          'imageUrl': data['imageUrl'] ?? '',
        };
      }).toList(),
      'transactions': transactionsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'categoria': data['categoria'] ?? '',
          'descricao': data['descricao'] ?? '',
          'valor': (data['valor'] ?? 0.0).toDouble(),
          'tipo': data['tipo'] ?? 'despesa',
          'status': data['status'] ?? 'Recebido',
        };
      }).toList(),
      'backupDate': DateTime.now().toIso8601String(),
    };

    return jsonEncode(backupData);
  }

  Future<void> restaurarBackup(String jsonString) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilizador não autenticado.');

    final Map<String, dynamic> data = jsonDecode(jsonString);
    final familyId = user.uid;
    final familyRef = _db.collection('families').doc(familyId);

    await zerarBancoDados();

    if (data['familyInfo'] != null && (data['familyInfo'] as Map).isNotEmpty) {
      await familyRef.set(Map<String, dynamic>.from(data['familyInfo']));
    }

    if (data['members'] != null) {
      for (var member in data['members']) {
        final String id = member['id'] ?? _db.collection('families').doc().id;
        final Map<String, dynamic> memberData = Map<String, dynamic>.from(member);
        memberData.remove('id');
        await familyRef.collection('members').doc(id).set(memberData);
      }
    }

    if (data['transactions'] != null) {
      for (var tx in data['transactions']) {
        final String id = tx['id'] ?? _db.collection('families').doc().id;
        final Map<String, dynamic> txData = Map<String, dynamic>.from(tx);
        txData.remove('id');
        await familyRef.collection('transactions').doc(id).set(txData);
      }
    }
  }
}
