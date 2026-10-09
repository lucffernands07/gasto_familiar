import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/family_service.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback onFamilyChanged;

  const CustomDrawer({super.key, required this.onFamilyChanged});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _activeFamilyId = 'familia_default';
  String _activeMode = 'individual';
  String? _sharedFamilyAdminUid;

  @override
  void initState() {
    super.initState();
    _loadDrawerState();
  }

  Future<void> _loadDrawerState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final familyId = await FamilyService().getActiveFamilyId();
    final mode = await FamilyService().getActiveMode();
    
    final prefs = await SharedPreferences.getInstance();
    final sharedAdmin = prefs.getString('shared_family_id_${user.uid}');

    if (mounted) {
      setState(() {
        _activeFamilyId = familyId;
        _activeMode = mode;
        _sharedFamilyAdminUid = sharedAdmin;
      });
    }
  }

  Future<void> _enviarConvite(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final nomeUsuario = user?.displayName ?? 'Um membro da família';
    final meuUid = user?.uid ?? '';
    
    const String baseUrl = 'https://lucffernands07.github.io/gasto_familiar/';
    final String linkComConvite = '$baseUrl?family=$meuUid';

    final assunto = Uri.encodeComponent('Convite Gasto Familiar ❤️📊');
    final corpo = Uri.encodeComponent(
      'Olá! Tudo bem?\n\n'
      '✨ O(A) $nomeUsuario está te convidando para participar do nosso painel de controle financeiro compartilhado!\n\n'
      '🔗 Para acessar o painel e entrar na família, clique no link abaixo:\n'
      'Convite Gasto Familiar ❤️📊: $linkComConvite\n\n'
      '💡 Basta fazer o login usando a sua conta de e-mail!'
    );

    final Uri uri = Uri(scheme: 'mailto', path: '', query: 'subject=$assunto&body=$corpo');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o aplicativo de e-mail.')),
        );
      }
    }
  }

  void _mostrarDialogEditarNomeBanco(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final nomeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EE),
        title: const Text('Nome do Banco Familiar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nomeController,
          decoration: const InputDecoration(
            labelText: 'Ex: Família Fernandes ou Lu & Nanda',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty) {
                await FamilyService().updateFamilyName(user.uid, nomeController.text);
                if (context.mounted) Navigator.pop(context);
                _loadDrawerState();
                widget.onFamilyChanged();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final nomeUsuario = user?.displayName ?? 'Usuário';
    final fallbackLetter = nomeUsuario.isNotEmpty ? nomeUsuario[0].toUpperCase() : 'U';

    return Drawer(
      backgroundColor: const Color(0xFFFAF6EE),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFFFCBDD),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('families')
                  .doc(_activeFamilyId)
                  .collection('members')
                  .snapshots(),
              builder: (context, memberSnapshot) {
                int totalMembros = 0;
                if (memberSnapshot.hasData) {
                  totalMembros = memberSnapshot.data!.docs.length;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? Text(
                              fallbackLetter,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nomeUsuario,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    Text(
                      _activeMode == 'individual'
                          ? 'Modo: Individual'
                          : '$totalMembros ${totalMembros == 1 ? 'membro conectado' : 'membros conectados'}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                    ),
                  ],
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Início'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text('Gerenciar Contas / Bancos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          // Alternar para Modo Individual
          ListTile(
            leading: Icon(Icons.person, color: _activeMode == 'individual' ? Colors.blue : Colors.grey),
            title: const Text('Meus Gastos (Individual)'),
            trailing: _activeMode == 'individual' ? const Icon(Icons.check, color: Colors.blue) : null,
            onTap: () async {
              await FamilyService().setActiveMode('individual');
              if (context.mounted) Navigator.pop(context);
              _loadDrawerState();
              widget.onFamilyChanged();
            },
          ),
          // Alternar para Conta Família Compartilhada (se o usuário tiver recebido/aceitado um convite)
          if (_sharedFamilyAdminUid != null)
            ListTile(
              leading: Icon(Icons.people, color: _activeMode != 'individual' ? Colors.pink : Colors.grey),
              title: const Text('Conta Família Compartilhada'),
              trailing: _activeMode != 'individual' ? const Icon(Icons.check, color: Colors.pink) : null,
              onTap: () async {
                await FamilyService().setActiveMode(_sharedFamilyAdminUid!);
                if (context.mounted) Navigator.pop(context);
                _loadDrawerState();
                widget.onFamilyChanged();
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_add_alt_outlined),
            title: const Text('Convidar Familiar'),
            onTap: () {
              Navigator.pop(context);
              _enviarConvite(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              _mostrarDialogEditarNomeBanco(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sair', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
