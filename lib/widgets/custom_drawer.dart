import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<void> _enviarConvite(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final nomeUsuario = user?.displayName ?? 'Um membro da família';
    final meuUid = user?.uid ?? '';
    
    // Link do seu GitHub Pages enviando o seu UID como parâmetro de convite
    const String baseUrl = 'https://lucffernands07.github.io/gasto_familiar/';
    final String linkComConvite = '$baseUrl?family=$meuUid';

    final assunto = Uri.encodeComponent('Convite Gasto Familiar ❤️📊');
    final corpo = Uri.encodeComponent(
      'Olá! Tudo bem?\n\n'
      '✨ O(A) $nomeUsuario está te convidando para participar do nosso painel de controle financeiro!\n\n'
      '━━━━━━━━━━━━━━━━━━━━━━━\n'
      '📊 O QUE VOCÊ VAI PODER FAZER:\n'
      '• Acompanhar saldos e despesas da casa\n'
      '• Registrar novos lançamentos em tempo real\n'
      '• Manter o orçamento familiar sincronizado\n'
      '━━━━━━━━━━━━━━━━━━━━━━━\n\n'
      '🔗 Para acessar o painel compartilhado e entrar na família, clique no link abaixo:\n'
      'Convite Gasto Familiar ❤️📊: $linkComConvite\n\n'
      '💡 Dica: Basta fazer o login usando a sua conta de e-mail e você já estará conectado automaticamente!\n\n'
      'Te esperamos lá! 🚀'
    );

    final Uri uri = Uri(
      scheme: 'mailto',
      path: '', 
      query: 'subject=$assunto&body=$corpo',
    );

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final familyId = user?.uid ?? 'familia_default';
    final photoUrl = user?.photoURL;
    final fallbackLetter = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName![0].toUpperCase()
        : 'U';

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
                  .doc(familyId)
                  .collection('members')
                  .snapshots(),
              builder: (context, snapshot) {
                int totalMembros = 0;
                if (snapshot.hasData) {
                  totalMembros = snapshot.data!.docs.length;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? Text(
                              fallbackLetter,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.displayName ?? 'Família',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    Text(
                      '$totalMembros ${totalMembros == 1 ? 'membro conectado' : 'membros conectados'}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
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
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Membros da Família'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categorias'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Relatórios & Extrato'),
            onTap: () {},
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
            onTap: () {},
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
