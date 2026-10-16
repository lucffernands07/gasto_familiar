import 'package:flutter/material.dart';

class VisaoGeralView extends StatelessWidget {
  final String familyId;
  final bool mostrarSaldo;
  final DateTime mesSelecionado;
  final Function(BuildContext, String, Map<String, dynamic>) onEditMember;
  final Function(BuildContext, String) onDeleteMember;
  final VoidCallback onCreateMember;

  const VisaoGeralView({
    super.key,
    required this.familyId,
    required this.mostrarSaldo,
    required this.mesSelecionado,
    required this.onEditMember,
    required this.onDeleteMember,
    required this.onCreateMember,
  });

  @override
  Widget build(BuildContext context) {
    // Vista geral limpa, sem a lista de membros por baixo do cartão principal,
    // mantendo o foco total no HeroCard e na Planilha.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEBE4)),
      ),
      child: Column(
        children: const [
          Icon(Icons.dashboard_outlined, size: 40, color: Color(0xFF888888)),
          SizedBox(height: 10),
          Text(
            'Visão Geral do Mês',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          SizedBox(height: 4),
          Text(
            'Consulte os totais acima ou deslize para a direita para ver a Planilha detalhada.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}
