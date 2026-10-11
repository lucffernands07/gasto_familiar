import 'package:flutter/material.dart';

class PlanilhaView extends StatelessWidget {
  const PlanilhaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEBE4)),
      ),
      child: const Column(
        children: [
          Icon(Icons.table_chart_outlined, size: 48, color: Color(0xFF888888)),
          SizedBox(height: 12),
          Text('Tela de Planilha Detalhada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          SizedBox(height: 6),
          Text('Em breve aqui estarão listadas todas as movimentações detalhadas.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
        ],
      ),
    );
  }
}
