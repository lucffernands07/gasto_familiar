import 'package:cloud_firestore/cloud_firestore.dart';

class PlanejamentoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot> carregarPlaneamento(String familyId) async {
    return await _db.collection('families').doc(familyId).collection('planejamento').doc('viagem_atual').get();
  }

  Future<void> salvarPlaneamento(String familyId, String titulo, List eventos) async {
    await _db.collection('families').doc(familyId).collection('planejamento').doc('viagem_atual').set({
      'titulo': titulo,
      'eventos': eventos,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
