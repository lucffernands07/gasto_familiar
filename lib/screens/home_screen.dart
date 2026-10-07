import 'package:flutter/material.dart';
import '../models/membro.dart';
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

  final List<Membro> _membros = const [
    Membro(nome: 'Ana', saldo: 1500.00, imageUrl: 'https://i.pravatar.cc/150?img=47', borderColor: Color(0xFFFFB7B2)),
    Membro(nome: 'Pedro', saldo: 1850.75, imageUrl: 'https://i.pravatar.cc/150?img=12', borderColor: Color(0xFFA8DADC)),
    Membro(nome: 'Lucas', saldo: 1000.00, imageUrl: 'https://i.pravatar.cc/150?img=60', borderColor: Color(0xFFB5EAD7)),
  ];

  @override
  Widget build(BuildContext context) {
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
              _buildTopBar(context),
              const SizedBox(height: 20),
              HeroCard(
                mostrarSaldo: _mostrarSaldo,
                onToggleVisibility: () => setState(() => _mostrarSaldo = !_mostrarSaldo),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context),
              const SizedBox(height: 12),
              ..._membros.map((membro) => MembroTile(membro: membro, mostrarSaldo: _mostrarSaldo)),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingButton(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
        Row(
          children: [
            const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47')),
            const SizedBox(width: 6),
            const Text('Ana', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.settings_outlined, size: 18, color: Color(0xFF666666)),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Atualizar meu Saldo', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Novo Saldo (R\$)', hintText: 'Ex: 1500,00', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            child: const Text('Salvar', style: TextStyle(color: Color(0xFF2C3E50))),
          ),
        ],
      ),
    );
  }

  void _mostrarModalLancamento(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF6EE),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Novo Lançamento / Editar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Descrição', hintText: 'Ex: Mercado, Luz, Salário', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            const TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Valor (R\$)', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB7B2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Confirmar', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
