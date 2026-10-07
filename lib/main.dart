import 'package:flutter/material.dart';

void main() {
  runApp(const GastoFamiliarApp());
}

class GastoFamiliarApp extends StatelessWidget {
  const GastoFamiliarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gasto Familiar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFAF6EE),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _mostrarSaldo = true;

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
              // 1. Barra Superior (Topo)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu_rounded, size: 32, color: Color(0xFF333333)),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const Text(
                    'Gasto Familiar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A4A4A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Ana',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
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
              ),
              const SizedBox(height: 20),

              // 2. Card Principal Resumo (Visão Geral)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFCBDD), Color(0xFFFFF3E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Texto Superior do Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Olá, Ana! Este mês:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        Text(
                          'Visão Geral',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Saldo Total
                    const Text(
                      'Saldos Totais:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _mostrarSaldo ? 'R\$ 4.350,75' : 'R\$ ••••••',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _mostrarSaldo = !_mostrarSaldo;
                            });
                          },
                          child: Icon(
                            _mostrarSaldo ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 22,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Card Interno - Receitas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFA8E6CF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Receitas',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555555),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'R\$ 6.100,00',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF222222),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card Interno - Gastos
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF8B94),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_downward_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Gastos',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555555),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'R\$ 1.749,25',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF222222),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Seção "Saldos por Membro"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saldos por Membro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _mostrarDialogAtualizarSaldo(context);
                    },
                    icon: const Icon(Icons.edit, size: 14, color: Color(0xFF4A4A4A)),
                    label: const Text(
                      'Atualizar meu Saldo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFEBE4),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFDCD6CD)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista de Membros
              MembroTile(
                nome: 'Ana',
                saldo: _mostrarSaldo ? 'R\$ 1.500,00' : 'R\$ ••••••',
                imageUrl: 'https://i.pravatar.cc/150?img=47',
                borderColor: const Color(0xFFFFB7B2),
              ),
              MembroTile(
                nome: 'Pedro',
                saldo: _mostrarSaldo ? 'R\$ 1.850,75' : 'R\$ ••••••',
                imageUrl: 'https://i.pravatar.cc/150?img=12',
                borderColor: const Color(0xFFA8DADC),
              ),
              MembroTile(
                nome: 'Lucas',
                saldo: _mostrarSaldo ? 'R\$ 1.000,00' : 'R\$ ••••••',
                imageUrl: 'https://i.pravatar.cc/150?img=60',
                borderColor: const Color(0xFFB5EAD7),
              ),

              const SizedBox(height: 80), // Espaço para o botão flutuante
            ],
          ),
        ),
      ),

      // 4. Botão Flutuante Centralizado "+ Lançar / Editar"
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton(
          onPressed: () {
            _mostrarModalLancamento(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4E6F1),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add, color: Color(0xFF2C3E50), size: 22),
              SizedBox(width: 6),
              Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2C3E50), size: 20),
              SizedBox(width: 8),
              Text(
                'Lançar / Editar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modal para atualizar o saldo individual
  void _mostrarDialogAtualizarSaldo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Atualizar meu Saldo', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Novo Saldo (R\$)',
            hintText: 'Ex: 1500,00',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            child: const Text('Salvar', style: TextStyle(color: Color(0xFF2C3E50))),
          ),
        ],
      ),
    );
  }

  // Modal para novo lançamento ou edição
  void _mostrarModalLancamento(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF6EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Novo Lançamento / Editar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Descrição',
                hintText: 'Ex: Mercado, Luz, Salário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
    );
  }
}

// Card Individual de Membro
class MembroTile extends StatelessWidget {
  final String nome;
  final String saldo;
  final String imageUrl;
  final Color borderColor;

  const MembroTile({
    super.key,
    required this.nome,
    required this.saldo,
    required this.imageUrl,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$nome:',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                saldo,
                style: const TextStyle(
               
