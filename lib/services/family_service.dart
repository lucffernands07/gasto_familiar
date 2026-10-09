import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  // Retorna o ID ativo: se foi convidado para outra família, retorna o UID do dono da família. Senão, o do próprio usuário.
  Future<String> getActiveFamilyId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'familia_default';

    final prefs = await SharedPreferences.getInstance();
    // Verifica se há um ID de família compartilhado guardado para este usuário
    String? sharedFamilyId = prefs.getString('shared_family_id_${user.uid}');
    
    // Se não tiver nenhuma família compartilhada vinculada, usa o próprio UID (espaço privado)
    return sharedFamilyId ?? user.uid;
  }

  // Vincular a uma família compartilhada (ao aceitar um convite ou link)
  Future<void> joinFamily(String adminUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shared_family_id_${user.uid}', adminUid);
  }

  // Desvincular/Voltar para a conta própria
  Future<void> leaveFamily() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shared_family_id_${user.uid}');
  }
}
