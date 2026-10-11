import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/membro.dart';
import '../services/family_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/hero_card.dart';
import '../widgets/membro_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _mostrarSaldo = true;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  String _familyId = 'familia_default';
  String _appTitle = 'Meus Gastos';

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    final activeId = await FamilyService().getActiveFamilyId();
    final title = await FamilyService().getAppTitle();
    setState(() {
      _familyId = activeId;
      _appTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userPhoto = user?.photoURL;
    final fallbackLetter = user?.email != null && user!.email!.isNotEmpty ? user.email![0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      drawer: CustomDrawer(
        onFamilyChanged: () {
          _carregarDadosIniciais();
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context, userPhoto, fallbackLetter),
              const SizedBox(height: 20),
              
              StreamBuilder<QuerySnapshot>(
                stream: _db.collection('families').doc(_familyId).collection('members').snapshots(),
                builder: (context, snapshot) {
                  return HeroCard(
                    mostrarSaldo: _mostrarSaldo,
                    onToggleVisibility: () => setState(() => _mostrarSaldo = !_mostrarSaldo),
                  );
                },
              ),

              const SizedBox(height: 24),
              _buildSectionHeader(context),
              const SizedBox(height: 12),
              
              StreamBuilder<QuerySnapshot>(
                stream: _db.collection('families').doc(_familyId).collection('members').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF4A4A4A))),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Nenhum membro registrado. Clique em "Adicionar Membro" para começar!',
                        style: TextStyle(color: Color(0xFF666666)),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;
                  final membros = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Membro(
                      nome: data['nome'] ?? 'Membro',
                      saldo: (data['saldo'] ?? 0.0).toDouble(),
                      imageUrl: data['imageUrl'] ?? 'https://i.pravatar.cc/150?img=12',
                      borderColor: const Color(0xFFA8DADC),
                    );
                  }).toList();

                  return Column(
                    children: membros.map((membro) => MembroTile(membro: membro, mostrarSaldo: _mostrarSaldo)).toList(),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingButton(context),
    );
  }

  Widget _buildTopBar(BuildContext context, String? photoUrl, String fallbackLetter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 32, color: Color(0xFF333333)),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        Text(
          _appTitle,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF4A4A4A), letterSpacing: -0.5),
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFFFCBDD),
          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
              ? (photoUrl.startsWith('data:image')
                  ? MemoryImage(base64Decode(photoUrl.split(',')[1])) as ImageProvider
                  : NetworkImage(photoUrl))
              : null,
          child: photoUrl == null || photoUrl.isEmpty
              ? Text(fallbackLetter, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)))
              : null,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Saldos por Membro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
        ElevatedButton.icon(
          onPressed: () => _mostrarDialogCriarMembro(context),
          icon: const Icon(Icons.person_add, size: 14, color: Color(0xFF4A4A4A)),
          label: const Text('Adicionar Membro', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A))),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEFEBE4),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFDCD6CD))),
          ),
        ),
      ],
    );
  }

  void _mostrarDialogCriarMembro(BuildContext context) {
    final nomeController = TextEditingController();
    final saldoController = TextEditingController();
    String? fotoBase64Selecionada;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFFFAF6EE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Criar Novo Membro', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 400,
                      maxHeight: 400,
                      imageQuality: 80,
                    );
                    if (pickedFile != null) {
                      final bytes = await pickedFile.readAsBytes();
                      setStateDialog(() {
                        fotoBase64Selecionada = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: fotoBase64Selecionada != null
                        ? MemoryImage(base64Decode(fotoBase64Selecionada!.split(',')[1]))
                        : null,
                    child: fotoBase64Selecionada == null
                        ? const Icon(Icons.add_a_photo, size: 28, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Toque para escolher foto', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome do Membro', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: saldoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Saldo Inicial (R\$)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final nome = nomeController.text.trim();
                final saldo = double.tryParse(saldoController.text.replaceAll(',', '.')) ?? 0.0;

                if (nome.isNotEmpty) {
                  final membroId = _db.collection('families').doc(_familyId).collection('members').doc().id;
                  await _db.collection('families').doc(_familyId).collection('members').doc(membroId).set({
                    'nome': nome,
                    'saldo': saldo,
                    'imageUrl': fotoBase64Selecionada ?? 'https://i.pravatar.cc/150?img=12',
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
              child: const Text('Criar', style: TextStyle(color: Color(0xFF2C3E50))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4E6F1),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, color: Color(0xFF2C3E50), size: 22),
            SizedBox(width: 6),
            Text('Lançar / Editar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
          ],
        ),
      ),
    );
  }
}
