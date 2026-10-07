import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFAF6EE),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFFFCBDD),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                ),
                SizedBox(height: 10),
                Text(
                  'Família Silva',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                Text(
                  '3 membros conectados',
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
              ],
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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
