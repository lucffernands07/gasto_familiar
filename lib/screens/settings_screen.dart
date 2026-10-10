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
  final _titleController = TextEditingController();
  final _greetingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarConfigs();
  }

  Future<void> _carregarConfigs() async {
    final title = await FamilyService().getAppTitle();
    final greeting = await FamilyService().getGreetingName();
    if (mounted) {
      setState(() {
        _titleController.text = title;
        _greetingController.text = greeting;
      });
    }
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
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
                const Text('Personalização da Tela Inicial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título da Tela Inicial (Ex: Meus Gastos)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _greetingController,
                  decoration: const InputDecoration(labelText: 'Nome no Card de Visão Geral (Ex: Luciano)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
                  onPressed: () async {
                    await FamilyService().setAppTitle(_titleController.text);
                    await FamilyService().setGreetingName(_greetingController.text);
                    _mostrarMensagem('Configurações salvas com sucesso!');
                  },
                  child: const Text('Salvar Alterações Visuais', style: TextStyle(color: Color(0xFF2C3E50))),
                ),
                const SizedBox(height: 24),
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
                          _mostrarMensagem('UID copiado!');
                        },
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
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text('Zerar Banco de Dados', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onPressed: () {},
                  onTap: () async {
                    // Confirmação para zerar
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Zerar Banco'),
                        content: const Text('Tem certeza que deseja apagar tudo?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            onPressed: () async {
                              Navigator.pop(context);
                              setState(() => _isLoading = true);
                              await FamilyService().zerarBancoDados();
                              setState(() => _isLoading = false);
                              _mostrarMensagem('Banco zerado com sucesso.');
                            },
                            child: const Text('Zerar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
