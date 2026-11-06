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

  // Função auxiliar para limpar timestamps e objetos não encodáveis
  Map<String, dynamic> _sanitizarDados(Map<String, dynamic> rawData) {
    final Map<String, dynamic> mapaLimpo = {};
    rawData.forEach((key, value) {
      if (value is Timestamp) {
        mapaLimpo[key] = value.toDate().toIso8601String();
      } else if (value is Map<String, dynamic>) {
        mapaLimpo[key] = _sanitizarDados(value);
      } else if (value is List) {
        mapaLimpo[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _sanitizarDados(item);
          } else if (item is Timestamp) {
            return item.toDate().toIso8601String();
          }
          return item;
        }).toList();
      } else {
        mapaLimpo[key] = value;
      }
    });
    return mapaLimpo;
  }

  Future<String> fazerBackup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilizador não autenticado.');

    final familyId = user.uid;
    final familyDoc = await _db.collection('families').doc(familyId).get();
    final membersSnapshot = await _db.collection('families').doc(familyId).collection('members').get();
    final transactionsSnapshot = await _db.collection('families').doc(familyId).collection('transactions').get();
    final historySnapshot = await _db.collection('families').doc(familyId).collection('history').get();

    // Sanitiza as informações principais da família
    Map<String, dynamic> familyInfoClean = {};
    if (familyDoc.exists && familyDoc.data() != null) {
      familyInfoClean = _sanitizarDados(familyDoc.data()!);
    }

    // Validação e estruturação explícita para o Backup
    final Map<String, dynamic> backupData = {
      'familyInfo': familyInfoClean,
      'members': membersSnapshot.docs.map((doc) {
        final data = _sanitizarDados(doc.data());
        return {
          'id': doc.id,
          'nome': data['nome']?.toString() ?? 'Sem Nome',
          'saldo': (data['saldo'] ?? 0.0).toDouble(),
          'imageUrl': data['imageUrl']?.toString() ?? '',
        };
      }).toList(),
      'transactions': transactionsSnapshot.docs.map((doc) {
        final data = _sanitizarDados(doc.data());
        return {
          'id': doc.id,
          'categoria': data['categoria']?.toString() ?? 'Geral',
          'descricao': data['descricao']?.toString() ?? '',
          'valor': (data['valor'] ?? 0.0).toDouble(),
          'tipo': data['tipo']?.toString() ?? 'despesa',
          'status': data['status']?.toString() ?? 'Pendente',
          'createdAt': data['createdAt'],
        };
      }).toList(),
      'history': historySnapshot.docs.map((doc) {
        final data = _sanitizarDados(doc.data());
        return {
          'acao': data['acao']?.toString() ?? 'Ação',
          'detalhes': data['detalhes']?.toString() ?? '',
          'usuario': data['usuario']?.toString() ?? '',
          'ip': data['ip']?.toString() ?? '',
          'createdAt': data['createdAt'],
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

    // Limpa a base atual antes de aplicar os dados validados
    await zerarBancoDados();

    // Valida e restaura informações gerais da família
    if (data['familyInfo'] != null && (data['familyInfo'] as Map).isNotEmpty) {
      await familyRef.set(Map<String, dynamic>.from(data['familyInfo']));
    }

    // Valida e restaura os membros
    if (data['members'] != null && data['members'] is List) {
      for (var member in data['members']) {
        if (member is Map) {
          final String id = member['id']?.toString() ?? _db.collection('families').doc().id;
          await familyRef.collection('members').doc(id).set({
            'nome': member['nome']?.toString() ?? 'Sem Nome',
            'saldo': (member['saldo'] ?? 0.0).toDouble(),
            'imageUrl': member['imageUrl']?.toString() ?? '',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    // Valida e restaura as transações (Planilha) preservando IDs e campos exatos
    if (data['transactions'] != null && data['transactions'] is List) {
      for (var tx in data['transactions']) {
        if (tx is Map) {
          final String id = tx['id']?.toString() ?? _db.collection('families').doc().id;
          
          // Trata a data de criação caso exista no backup
          dynamic createdAtValue = FieldValue.serverTimestamp();
          if (tx['createdAt'] != null) {
            final parsedDate = DateTime.tryParse(tx['createdAt'].toString());
            if (parsedDate != null) {
              createdAtValue = Timestamp.fromDate(parsedDate);
            }
          }

          await familyRef.collection('transactions').doc(id).set({
            'categoria': tx['categoria']?.toString() ?? 'Geral',
            'descricao': tx['descricao']?.toString() ?? '',
            'valor': (tx['valor'] ?? 0.0).toDouble(),
            'tipo': tx['tipo']?.toString() ?? 'despesa',
            'status': tx['status']?.toString() ?? 'Pendente',
            'createdAt': createdAtValue,
          });
        }
      }
    }

    // Valida e restaura o histórico antigo
    if (data['history'] != null && data['history'] is List) {
      for (var hist in data['history']) {
        if (hist is Map) {
          dynamic createdAtValue = FieldValue.serverTimestamp();
          if (hist['createdAt'] != null) {
            final parsedDate = DateTime.tryParse(hist['createdAt'].toString());
            if (parsedDate != null) {
              createdAtValue = Timestamp.fromDate(parsedDate);
            }
          }

          await familyRef.collection('history').add({
            'acao': hist['acao']?.toString() ?? 'Histórico',
            'detalhes': hist['detalhes']?.toString() ?? '',
            'usuario': hist['usuario']?.toString() ?? user.email ?? '',
            'ip': hist['ip']?.toString() ?? 'Sistema',
            'createdAt': createdAtValue,
          });
        }
      }
    }

    // Identifica o dispositivo atual e regista a auditoria de restauração bem-sucedida
    final prefs = await SharedPreferences.getInstance();
    final nomeDispositivo = prefs.getString('device_nickname') ?? 'Dispositivo Padrão';

    await familyRef.collection('history').add({
      'acao': 'Restauração',
      'detalhes': 'Banco de dados restaurado e validado via arquivo JSON',
      'usuario': user.email ?? 'Usuário',
      'ip': nomeDispositivo,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
