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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            icon: Icon(Icons.chevron_left, color: textColor),
            onPressed: () => onMudarMes(-1),
          ),
          Text(
            textoMes,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: textColor),
            onPressed: () => onMudarMes(1),
          ),
        ],
      ),
    );
  }
}
