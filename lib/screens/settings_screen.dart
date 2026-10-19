import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import '../services/family_service.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  const SettingsScreen({super.key, required this.isDarkMode});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  final _titleController = TextEditingController();
  final _greetingController = TextEditingController();
  final _deviceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarConfigs();
  }

  Future<void> _carregarConfigs() async {
    final title = await FamilyService().getAppTitle();
    final greeting = await FamilyService().getGreetingName();
    
    final prefs = await SharedPreferences.getInstance();
    final deviceName = prefs.getString('device_nickname') ?? '';

    if (mounted) {
      setState(() {
        _titleController.text = title;
        _greetingController.text = greeting;
        _deviceController.text = deviceName;
      });
    }
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // Função para processar a exclusão segura da conta
  void _confirmarEExcluirConta(BuildContext context, User? user, Color cardColor, Color textColor, Color subtitleColor) {
    final emailController = TextEditingController();
    final emailLogado = user?.email ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Eliminar Conta', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza absoluta de que deseja eliminar a sua conta e todos os dados associados? Esta ação é irreversível.',
              style: TextStyle(color: subtitleColor, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              'Para confirmar, digite o seu e-mail ($emailLogado):',
              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              style: TextStyle(color: textColor),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Digite o seu e-mail aqui',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final emailDigitado = emailController.text.trim();
              if (emailDigitado != emailLogado) {
                _mostrarMensagem('O e-mail digitado não corresponde à conta atual.');
                return;
              }

              Navigator.pop(context); // Fecha o dialog
              setState(() => _isLoading = true);

              try {
                // Envia email informativo do Firebase antes de excluir
                await user?.sendEmailVerification(); // Ou envio de aviso personalizado se aplicável
                
                // Exclui a conta do Firebase Auth
                await user?.delete();

                // Limpa os dados locais de termos/preferências
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                _mostrarMensagem('Conta eliminada com sucesso. Uma nova conta poderá ser criada ao entrar novamente.');
              } catch (e) {
                _mostrarMensagem('Erro ao excluir conta: $e. Poderá ser necessário reautenticar-se.');
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Eliminar Definitivamente', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'Não autenticado';

    final Color bgColor = widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAF6EE);
    final Color cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = widget.isDarkMode ? Colors.white : const Color(0xFF333333);
    final Color subtitleColor = widget.isDarkMode ? Colors.white70 : const Color(0xFF666666);
    final Color borderColor = widget.isDarkMode ? Colors.white24 : const Color(0xFFDCD6CD);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFCBDD),
        title: Text('Configurações', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: textColor))
          : ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Text('Identificação deste Aparelho', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 6),
                Text('Define um nome para identificar este telemóvel no histórico de edições.', style: TextStyle(fontSize: 12, color: subtitleColor)),
                const SizedBox(height: 12),
                TextField(
                  controller: _deviceController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Nome do Aparelho (Ex: Celular do Lu)',
                    labelStyle: TextStyle(color: subtitleColor),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Personalização da Tela Inicial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Título da Tela Inicial (Ex: Meus Gastos)',
                    labelStyle: TextStyle(color: subtitleColor),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _greetingController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Nome no Card de Visão Geral (Ex: Luciano)',
                    labelStyle: TextStyle(color: subtitleColor),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
                  onPressed: () async {
                    await FamilyService().setAppTitle(_titleController.text);
                    await FamilyService().setGreetingName(_greetingController.text);
                    
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('device_nickname', _deviceController.text.trim());

                    _mostrarMensagem('Configurações salvas com sucesso!');
                  },
                  child: const Text('Salvar Alterações', style: TextStyle(color: Color(0xFF2C3E50))),
                ),
                const SizedBox(height: 24),
                Text('Gestão de Dados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.download, color: Colors.blue),
                  title: Text('Fazer Backup', style: TextStyle(color: textColor)),
                  subtitle: Text('Baixar arquivo .json de backup', style: TextStyle(color: subtitleColor)),
                  onTap: () async {
                    setState(() => _isLoading = true);
                    try {
                      final jsonString = await FamilyService().fazerBackup();
                      final bytes = utf8.encode(jsonString);
                      
                      await FileSaver.instance.saveFile(
                        name: 'gasto_familiar_backup_${DateTime.now().millisecondsSinceEpoch}',
                        bytes: Uint8List.fromList(bytes),
                        ext: 'json',
                        mimeType: MimeType.json,
                      );
                      
                      _mostrarMensagem('Backup baixado com sucesso!');
                    } catch (e) {
                      _mostrarMensagem('Erro ao gerar backup: $e');
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.upload, color: Colors.green),
                  title: Text('Restaurar Backup', style: TextStyle(color: textColor)),
                  subtitle: Text('Selecionar arquivo .json ou colar texto', style: TextStyle(color: subtitleColor)),
                  onTap: () {
                    final controller = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: cardColor,
                        title: Text('Restaurar Backup', style: TextStyle(color: textColor)),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
                                icon: const Icon(Icons.folder_open, color: Color(0xFF2C3E50)),
                                label: const Text('Selecionar Ficheiro .json', style: TextStyle(color: Color(0xFF2C3E50))),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  
                                  List<PlatformFile> files = await FilePicker.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['json'],
                                  );         

                                  if (files.isNotEmpty) {
                                    PlatformFile file = files.first;
                                    Uint8List? fileBytes = await file.readAsBytes();

                                    if (fileBytes != null) {
                                      final jsonString = utf8.decode(fileBytes);
                                      setState(() => _isLoading = true);
                                      try {
                                        await FamilyService().restaurarBackup(jsonString);
                                        _mostrarMensagem('Restaurado com sucesso!');
                                      } catch (e) {
                                        _mostrarMensagem('Erro ao restaurar: $e');
                                      } finally {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text('Ou cole o código JSON abaixo:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: controller,
                                maxLines: 4,
                                style: TextStyle(color: textColor),
                                decoration: const InputDecoration(hintText: 'Cole o JSON aqui...', border: OutlineInputBorder()),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                          ElevatedButton(
                            onPressed: () async {
                              final text = controller.text.trim();
                              if (text.isNotEmpty) {
                                Navigator.pop(context);
                                setState(() => _isLoading = true);
                                try {
                                  await FamilyService().restaurarBackup(text);
                                  _mostrarMensagem('Restaurado com sucesso!');
                                } catch (e) {
                                  _mostrarMensagem('Erro ao restaurar: $e');
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                            child: const Text('Restaurar do Texto'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  tileColor: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text('Zerar Banco de Dados', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  subtitle: Text('Apagar todas as informações e transações', style: TextStyle(color: subtitleColor)),
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: cardColor,
                        title: Text('Zerar Banco', style: TextStyle(color: textColor)),
                        content: Text('Tem certeza que deseja apagar tudo?', style: TextStyle(color: subtitleColor)),
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
                const SizedBox(height: 12),
                // Botão de Excluir Conta posicionado antes da Identificação do Banco
                ListTile(
                  tileColor: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.person_remove_rounded, color: Colors.red),
                  title: const Text('Excluir Conta e Dados', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: Text('Remove permanentemente a conta e dados associados', style: TextStyle(color: subtitleColor)),
                  onTap: () => _confirmarEExcluirConta(context, user, cardColor, textColor, subtitleColor),
                ),
                const SizedBox(height: 24),
                // Identificação do Banco movida para o último lugar
                Text('Identificação do Banco', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('UID do Utilizador / Banco', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(uid, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: textColor),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: uid));
                          _mostrarMensagem('UID copiado!');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
