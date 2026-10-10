import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Apaga todos os dados do banco atual do usuário
  Future<void> zerarBancoDados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final familyId = user.uid;
    final familyRef = _db.collection('families').doc(familyId);

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

  // Gera um JSON com todos os dados do banco para Backup
  Future<String> fazerBackup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilizador não autenticado.');

    final familyId = user.uid;
    final familyDoc = await _db.collection('families').doc(familyId).get();
    
    final membersSnapshot = await _db.collection('families').doc(familyId).collection('members').get();
    final transactionsSnapshot = await _db.collection('families').doc(familyId).collection('transactions').get();

    final Map<String, dynamic> backupData = {
      'familyInfo': familyDoc.exists ? familyDoc.data() : {},
      'members': membersSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
      'transactions': transactionsSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
      'backupDate': DateTime.now().toIso8601String(),
    };

    return jsonEncode(backupData);
  }

  // Restaura os dados através de uma string JSON
  Future<void> restaurarBackup(String jsonString) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilizador não autenticado.');

    final Map<String, dynamic> data = jsonDecode(jsonString);
    final familyId = user.uid;
    final familyRef = _db.collection('families').doc(familyId);

    // Limpa o banco atual antes de restaurar
    await zerarBancoDados();

    // Restaura informações principais da família se existirem
    if (data['familyInfo'] != null && (data['familyInfo'] as Map).isNotEmpty) {
      await familyRef.set(data['familyInfo']);
    }

    // Restaura membros
    if (data['members'] != null) {
      for (var member in data['members']) {
        final String id = member['id'] ?? _db.collection('families').doc().id;
        final Map<String, dynamic> memberData = Map<String, dynamic>.from(member);
        memberData.remove('id');
        await familyRef.collection('members').doc(id).set(memberData);
      }
    }

    // Restaura transações
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
