import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String get familyId => currentUser?.uid ?? 'familia_default';

  // Ouve os membros e saldos individuais em tempo real
  Stream<QuerySnapshot> getMembersStream() {
    return _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .snapshots();
  }

  // Ouve todos os lançamentos em tempo real
  Stream<QuerySnapshot> getTransactionsStream() {
    return _db
        .collection('families')
        .doc(familyId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Atualiza o saldo do membro atual
  Future<void> updateMyBalance(double newBalance) async {
    final user = currentUser;
    if (user == null) return;

    await _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .doc(user.uid)
        .set({
      'name': user.displayName ?? user.email?.split('@')[0] ?? 'Membro',
      'email': user.email,
      'balance': newBalance,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Regista uma nova receita ou despesa
  Future<void> addTransaction({
    required String description,
    required double amount,
    required String type,
  }) async {
    final user = currentUser;
    if (user == null) return;

    await _db
        .collection('families')
        .doc(familyId)
        .collection('transactions')
        .add({
      'description': description,
      'amount': amount,
      'type': type,
      'userId': user.uid,
      'userName': user.displayName ?? 'Membro',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
