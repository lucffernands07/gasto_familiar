import 'package:flutter/material.dart';

class HeroCard extends StatelessWidget {
  final bool mostrarSaldo;
  final VoidCallback onToggleVisibility;

  const HeroCard({
    super.key,
    required this.mostrarSaldo,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                mostrarSaldo ? 'R\$ 4.350,75' : 'R\$ ••••••',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  mostrarSaldo ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 22,
                  color: const Color(0xFF555555),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildItemCard('Receitas', 'R\$ 6.100,00', const Color(0xFFA8E6CF), Icons.arrow_upward_rounded),
          const SizedBox(height: 12),
          _buildItemCard('Gastos', 'R\$ 1.749,25', const Color(0xFFFF8B94), Icons.arrow_downward_rounded),
        ],
      ),
    );
  }

  Widget _buildItemCard(String titulo, String valor, Color corIcone, IconData icone) {
    return Container(
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
            decoration: BoxDecoration(color: corIcone, shape: BoxShape.circle),
            child: Icon(icone, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF222222))),
            ],
          ),
        ],
      ),
    );
  }
}
