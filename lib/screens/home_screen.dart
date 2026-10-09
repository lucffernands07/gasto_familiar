import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _familyId = 'familia_default';

  @override
  void initState() {
    super.initState();
    _carregarFamiliasEUrl();
  }

  // Verifica se veio um convite na URL e carrega o ID correto da família
  Future<void> _carregarFamiliasEUrl() async {
    if (kIsWeb) {
      try {
        final uri = Uri.parse(html.window.location.href);
        final familyAdminUid = uri.queryParameters['family'];
        if (familyAdminUid != null && familyAdminUid.isNotEmpty) {
          // Vincula o usuário ao banco de dados do administrador que convidou
          await FamilyService().joinFamily(familyAdminUid);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Você entrou na Conta Família com sucesso!')),
            );
          }
        }
      } catch (e) {
        debugPrint('Erro ao processar URL de convite: $e');
      }
    }

    // Obtém o ID ativo (seja o privado ou o da família compartilhada)
    final activeId = await FamilyService().getActiveFamilyId();
    setState(() {
      _familyId = activeId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final userPhoto = user?.photoURL;
    final fallbackLetter = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName![0].toUpperCase()
        : (user?.email != null && user!.email!.isNotEmpty ? user.email![0].toUpperCase() : 'U');

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context, userPhoto, fallbackLetter),
              const SizedBox(height: 20),
              HeroCard(
                mostrarSaldo: _mostrarSaldo,
                onToggleVisibility: () => setState(() => _mostrarSaldo = !_mostrarSaldo),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context),
              const SizedBox(height: 12),
              
              // Leitura em tempo real dos membros gravados no Firestore usando o _familyId ativo
              StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection('families')
                    .doc(_familyId)
                    .collection('members')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF4A4A4A)),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Nenhum membro registrado. Clique em "Atualizar meu Saldo" para começar!',
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
                    children: membros
                        .map((membro) => MembroTile(membro: membro, mostrarSaldo: _mostrarSaldo))
                        .toList(),
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
        const Text(
          'Gasto Familiar',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF4A4A4A), letterSpacing: -0.5),
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFFFCBDD),
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null
              ? Text(
                  fallbackLetter,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                )
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
          onPressed: () => _mostrarDialogAtualizarSaldo(context),
          icon: const Icon(Icons.edit, size: 14, color: Color(0xFF4A4A4A)),
          label: const Text('Atualizar meu Saldo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A))),
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

  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () => _mostrarModalLancamento(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4E6F1),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, color: Color(0xFF2C3E50), size: 22),
            SizedBox(width: 6),
            Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2C3E50), size: 20),
            SizedBox(width: 8),
            Text('Lançar / Editar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogAtualizarSaldo(BuildContext context) {
    final saldoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Atualizar meu Saldo', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: saldoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Novo Saldo (R\$)', hintText: 'Ex: 1500,00', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(saldoController.text.replaceAll(',', '.'));
              if (val != null) {
                final user = _auth.currentUser;
                final uid = user?.uid ?? 'anonimo';
                final nome = user?.displayName ?? user?.email?.split('@')[0] ?? 'Membro';
                final photo = user?.photoURL ?? 'https://i.pravatar.cc/150?img=12';

                // Grava no Firestore usando a família ativa (_familyId)
                await _db
                    .collection('families')
                    .doc(_familyId)
                    .collection('members')
                    .doc(uid)
                    .set({
                  'nome': nome,
                  'saldo': val,
                  'imageUrl': photo,
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            child: const Text('Salvar', style: TextStyle(color: Color(0xFF2C3E50))),
          ),
        ],
      ),
    );
  }

  void _mostrarModalLancamento(BuildContext context) {
    final descController = TextEditingController();
    final valorController = TextEditingController();
    String tipo = 'despesa';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF6EE),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 24.0,
            left: 24.0,
            right: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Novo Lançamento / Editar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descrição', hintText: 'Ex: Mercado, Luz, Salário', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor (R\$)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Despesa'),
                      value: 'despesa',
                      groupValue: tipo,
                      onChanged: (val) => setModalState(() => tipo = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Receita'),
                      value: 'receita',
                      groupValue: tipo,
                      onChanged: (val) => setModalState(() => tipo = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(valorController.text.replaceAll(',', '.'));
                    if (descController.text.isNotEmpty && amount != null) {
                      final user = _auth.currentUser;
                      
                      // Grava o lançamento no Firestore usando o _familyId ativo
                      await _db
                          .collection('families')
                          .doc(_familyId)
                          .collection('transactions')
                          .add({
                        'descricao': descController.text,
                        'valor': amount,
                        'tipo': tipo,
                        'userId': user?.uid,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB7B2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirmar', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
