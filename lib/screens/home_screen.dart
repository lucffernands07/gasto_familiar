import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/family_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/hero_card.dart';
import '../widgets/visao_geral_view.dart';
import '../widgets/planilha_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _mostrarSaldo = true;
  String _abaAtiva = 'visao_geral';
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

  void _mudarAba(String novaAba) {
    setState(() {
      _abaAtiva = novaAba;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userPhoto = user?.photoURL;
    final fallbackLetter = user?.email != null && user!.email!.isNotEmpty ? user.email![0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      drawer: CustomDrawer(onFamilyChanged: _carregarDadosIniciais),
      body: GestureDetector(
        // Adiciona suporte a gesto de arrastar para esquerda/direita
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // Arrastou para a esquerda -> Vai para Planilha
            if (_abaAtiva == 'visao_geral') _mudarAba('planilha');
          } else if (details.primaryVelocity! > 0) {
            // Arrastou para a direita -> Vai para Visão Geral
            if (_abaAtiva == 'planilha') _mudarAba('visao_geral');
          }
        },
        child: SafeArea(
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
                  abaAtiva: _abaAtiva,
                  onAbaChanged: _mudarAba,
                ),
                const SizedBox(height: 16),
                
                // Indicador visual com seta pedindo para arrastar / ver Planilha
                if (_abaAtiva == 'visao_geral')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF888888)),
                        SizedBox(width: 4),
                        Text(
                          'Arraste ou clique em Planilha',
                          style: TextStyle(fontSize: 12, color: Color(0xFF888888), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: Offset(_abaAtiva == 'planilha' ? 1.0 : -1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                  child: KeyedSubtree(
                    key: ValueKey<String>(_abaAtiva),
                    child: _abaAtiva == 'visao_geral'
                        ? VisaoGeralView(
                            familyId: _familyId,
                            mostrarSaldo: _mostrarSaldo,
                            onEditMember: _mostrarDialogEditarMembro,
                            onDeleteMember: _excluirMembro,
                            onCreateMember: () => _mostrarDialogCriarMembro(context),
                          )
                        : PlanilhaView(familyId: _familyId, mostrarSaldo: _mostrarSaldo),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
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
        Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, size: 32, color: Color(0xFF333333)),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        )),
        Text(_appTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF4A4A4A), letterSpacing: -0.5)),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFFFCBDD),
          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
              ? (photoUrl.startsWith('data:image') ? MemoryImage(base64Decode(photoUrl.split(',')[1])) as ImageProvider : NetworkImage(photoUrl))
              : null,
          child: photoUrl == null || photoUrl.isEmpty ? Text(fallbackLetter, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))) : null,
        ),
      ],
    );
  }

  void _mostrarDialogCriarMembro(BuildContext context) {
    final nomeController = TextEditingController();
    final saldoController = TextEditingController();
    String? fotoBase64;

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
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400, imageQuality: 80);
                    if (pickedFile != null) {
                      final bytes = await pickedFile.readAsBytes();
                      setStateDialog(() => fotoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}');
                    }
                  },
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: fotoBase64 != null ? MemoryImage(base64Decode(fotoBase64!.split(',')[1])) : null,
                    child: fotoBase64 == null ? const Icon(Icons.add_a_photo, size: 28, color: Colors.grey) : null,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Toque para escolher foto', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Membro', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: saldoController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Saldo Inicial (R\$)', border: OutlineInputBorder())),
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
                    'imageUrl': fotoBase64 ?? 'https://i.pravatar.cc/150?img=12',
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

  void _mostrarDialogEditarMembro(BuildContext context, String membroId, Map<String, dynamic> dadosAtuais) {
    final nomeController = TextEditingController(text: dadosAtuais['nome'] ?? '');
    final saldoController = TextEditingController(text: (dadosAtuais['saldo'] ?? 0.0).toString());
    String? fotoBase64 = dadosAtuais['imageUrl'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFFFAF6EE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Membro', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400, imageQuality: 80);
                    if (pickedFile != null) {
                      final bytes = await pickedFile.readAsBytes();
                      setStateDialog(() => fotoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}');
                    }
                  },
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: fotoBase64 != null && fotoBase64!.startsWith('data:image')
                        ? MemoryImage(base64Decode(fotoBase64!.split(',')[1]))
                        : (fotoBase64 != null ? NetworkImage(fotoBase64!) as ImageProvider : null),
                    child: fotoBase64 == null ? const Icon(Icons.add_a_photo, size: 28, color: Colors.grey) : null,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Toque para alterar foto', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Membro', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: saldoController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Saldo (R\$)', border: OutlineInputBorder())),
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
                  await _db.collection('families').doc(_familyId).collection('members').doc(membroId).update({
                    'nome': nome,
                    'saldo': saldo,
                    'imageUrl': fotoBase64 ?? 'https://i.pravatar.cc/150?img=12',
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
              child: const Text('Salvar', style: TextStyle(color: Color(0xFF2C3E50))),
            ),
          ],
        ),
      ),
    );
  }

  void _excluirMembro(BuildContext context, String membroId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Membro'),
        content: const Text('Tem certeza que deseja remover este membro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await _db.collection('families').doc(_familyId).collection('members').doc(membroId).delete();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () => _mostrarDialogLancarTransacao(context),
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
            Text('Lançar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogLancarTransacao(BuildContext context) {
    final valorController = TextEditingController();
    final descricaoController = TextEditingController();
    final categoriaController = TextEditingController(text: 'Receita');
    String tipoSelecionado = 'receita';
    String statusSelecionado = 'Recebido';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFFFAF6EE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Nova Transação', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Receita'),
                      selected: tipoSelecionado == 'receita',
                      selectedColor: const Color(0xFFA8E6CF),
                      onSelected: (selected) {
                        setStateDialog(() {
                          tipoSelecionado = 'receita';
                          categoriaController.text = 'Receita';
                          statusSelecionado = 'Recebido';
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Despesa'),
                      selected: tipoSelecionado == 'despesa',
                      selectedColor: const Color(0xFFFF8B94),
                      onSelected: (selected) {
                        setStateDialog(() {
                          tipoSelecionado = 'despesa';
                          categoriaController.text = 'Despesas Fixas';
                          statusSelecionado = 'Pago';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoriaController,
                  decoration: const InputDecoration(labelText: 'Nome da Coluna / Categoria', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição (Ex: Salário / Luz)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Valor (R\$)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: statusSelecionado,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: tipoSelecionado == 'receita'
                      ? const [
                          DropdownMenuItem(value: 'Recebido', child: Text('Recebido')),
                          DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                        ]
                      : const [
                          DropdownMenuItem(value: 'Pago', child: Text('Pago')),
                          DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                        ],
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => statusSelecionado = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final valor = double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0;
                final descricao = descricaoController.text.trim();
                final categoria = categoriaController.text.trim();

                if (valor > 0) {
                  final transId = _db.collection('families').doc(_familyId).collection('transactions').doc().id;
                  await _db.collection('families').doc(_familyId).collection('transactions').doc(transId).set({
                    'categoria': categoria.isNotEmpty ? categoria : (tipoSelecionado == 'receita' ? 'Receita' : 'Despesas'),
                    'descricao': descricao.isNotEmpty ? descricao : (tipoSelecionado == 'receita' ? 'Receita' : 'Despesa'),
                    'valor': valor,
                    'tipo': tipoSelecionado,
                    'status': statusSelecionado,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
              child: const Text('Salvar', style: TextStyle(color: Color(0xFF2C3E50))),
            ),
          ],
        ),
      ),
    );
  }
}
