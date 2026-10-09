import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Retorna o ID ativo do banco de dados (seja o individual do usuário ou a família compartilhada selecionada)
  Future<String> getActiveFamilyId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'familia_default';

    final prefs = await SharedPreferences.getInstance();
    // Verifica se o usuário escolheu o modo 'individual' ou se está numa família compartilhada
    String? modoAtivo = prefs.getString('modo_ativo_${user.uid}');

    if (modoAtivo == 'individual') {
      return user.uid; // Força o uso do espaço privado
    }
    
    // Se não tiver modo definido mas tiver uma família compartilhada vinculada, usa ela por padrão, senão o próprio UID
    String? sharedFamilyId = prefs.getString('shared_family_id_${user.uid}');
    return sharedFamilyId ?? user.uid;
  }

  // Retorna se o modo atual é 'individual' ou 'compartilhado'
  Future<String> getActiveMode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'individual';

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('modo_ativo_${user.uid}') ?? 'individual';
  }

  // Alternar o modo ativo ('individual' ou o UID do admin da família)
  Future<void> setActiveMode(String modeOrFamilyId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('modo_ativo_${user.uid}', modeOrFamilyId);
  }

  // Vincular a uma família compartilhada (ao aceitar o convite pelo link)
  Future<void> joinFamily(String adminUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    // Guarda o vínculo com a família e define como modo ativo automaticamente
    await prefs.setString('shared_family_id_${user.uid}', adminUid);
    await prefs.setString('modo_ativo_${user.uid}', adminUid);

    // Regista o usuário atual como membro na coleção da família do administrador
    await _db.collection('families').doc(adminUid).collection('members').doc(user.uid).set({
      'nome': user.displayName ?? user.email?.split('@')[0] ?? 'Membro',
      'email': user.email,
      'imageUrl': user.photoURL ?? 'https://i.pravatar.cc/150?img=12',
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Desvincular da família
  Future<void> leaveFamily() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shared_family_id_${user.uid}');
    await prefs.setString('modo_ativo_${user.uid}', 'individual');
  }

  // Obter detalhes do banco de dados familiar (como o nome personalizado)
  Future<Map<String, dynamic>?> getFamilyDetails(String familyId) async {
    final doc = await _db.collection('families').doc(familyId).get();
    return doc.data();
  }

  // Atualizar o nome personalizado do banco compartilhado (Apenas Administrador)
  Future<void> updateFamilyName(String familyId, String newName) async {
    await _db.collection('families').doc(familyId).set({
      'familyName': newName,
      'adminUid': familyId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
