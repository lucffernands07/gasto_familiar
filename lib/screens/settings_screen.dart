import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/family_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _confirmarZerarBanco(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EE),
        title: const Text('Zerar Banco de Dados', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Tem a certeza de que deseja apagar todos os dados e transações deste banco? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await FamilyService().zerarBancoDados();
                _mostrarMensagem('Banco de dados zerado com sucesso.');
              } catch (e) {
                _mostrarMensagem('Erro ao zerar o banco: $e');
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Zerar Tudo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _realizarBackup() async {
    setState(() => _isLoading = true);
    try {
      final jsonString = await FamilyService().fazerBackup();
      // Em ambiente Web ou Mobile, copiamos para a área de transferência ou exibimos
      await Clipboard.setData(ClipboardData(text: jsonString));
      _mostrarMensagem('Backup copiado para a área de transferência com sucesso!');
    } catch (e) {
      _mostrarMensagem('Erro ao gerar backup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restaurarBackupDialog(BuildContext context) async {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EE),
        title: const Text('Restaurar Backup', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Cole o código JSON do backup aqui...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            onPressed: () async {
              final jsonText = controller.text.trim();
              if (jsonText.isEmpty) return;

              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                // Valida se é um JSON correto
                jsonDecode(jsonText);
                await FamilyService().restaurarBackup(jsonText);
                _mostrarMensagem('Banco restaurado com sucesso!');
              } catch (e) {
                _mostrarMensagem('Erro ao restaurar: JSON inválido ou dados incorretos.');
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Restaurar', style: TextStyle(color: Color(0xFF2C3E50))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'Não autenticado';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCBDD),
        title: const Text('Configurações', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A4A4A)))
          : ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                const Text('Identificação do Banco', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDCD6CD)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('UID do Utilizador / Banco', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(uid, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Color(0xFF4A4A4A)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: uid));
                          _mostrarMensagem('UID copiado para a área de transferência!');
                        },
                        tooltip: 'Copiar UID',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Gestão de Dados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.download, color: Colors.blue),
                  title: const Text('Fazer Backup'),
                  subtitle: const Text('Exportar dados copiando para o clipboard'),
                  onTap: _realizarBackup,
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.upload, color: Colors.green),
                  title: const Text('Restaurar Backup'),
                  subtitle: const Text('Importar dados através de um código JSON'),
                  onTap: () => _restaurarBackupDialog(context),
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text('Zerar Banco de Dados', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Apagar todas as informações e transações'),
                  onTap: () => _confirmarZerarBanco(context),
                ),
              ],
            ),
    );
  }
}
