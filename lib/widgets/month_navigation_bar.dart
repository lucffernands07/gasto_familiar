import 'package:flutter/material.dart';

class MonthNavigationBar extends StatelessWidget {
  final DateTime mesSelecionado;
  final Color textColor;
  final bool isDarkMode;
  final ValueChanged<int> onMudarMes;

  const MonthNavigationBar({
    super.key,
    required this.mesSelecionado,
    required this.textColor,
    required this.isDarkMode,
    required this.onMudarMes,
  });

  @override
  Widget build(BuildContext context) {
    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    String textoMes = '${meses[mesSelecionado.month - 1]} ${mesSelecionado.year}';

    final agora = DateTime.now();
    final bool ehMesAtual =
        mesSelecionado.year == agora.year && mesSelecionado.month == agora.month;

    final List<Color> coresGradiente = ehMesAtual
        ? [const Color(0xFFFFCBDD), const Color(0xFFFFF3E0)]
        : [const Color(0xFF4A4A4A), const Color(0xFF888888)];

    final Color corConteudo = ehMesAtual ? const Color(0xFF333333) : Colors.white;
    final Color corBorda = ehMesAtual
        ? const Color(0xFFC7B8B0)
        : const Color(0xFFB0B0B0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: coresGradiente,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: corBorda,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: corConteudo),
            onPressed: () => onMudarMes(-1),
          ),
          Text(
            textoMes,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: corConteudo,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: corConteudo),
            onPressed: () => onMudarMes(1),
          ),
        ],
      ),
    );
  }
}
