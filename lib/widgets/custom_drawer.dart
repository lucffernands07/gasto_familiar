import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/family_service.dart';
import '../screens/settings_screen.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback onFamilyChanged;

  const CustomDrawer({super.key, required this.onFamilyChanged});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  void _mostrarDialogEditarFoto(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final controller = TextEditingController(text: user?.photoURL ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EE),
        title: const Text('Editar Imagem de Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'URL da Imagem (Ex: https://...)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            onPressed: () async {
              try {
                await user?.updatePhotoURL(controller.text.trim());
                if (context.mounted) Navigator.pop(context);
                setState(() {});
                widget.onFamilyChanged();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar foto: $e')));
              }
            },
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
            decoration: const BoxDecoration(color: Color(0xFFFFCBDD)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _mostrarDialogEditarFoto(context),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null || photoUrl.isEmpty
                            ? Text(fallbackLetter, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)))
                            : null,
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.edit, size: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(nomeUsuario, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const Text('Toque na foto para editar', style: TextStyle(fontSize: 11, color: Color(0xFF666666))),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Início'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())).then((_) => widget.onFamilyChanged());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sair', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
