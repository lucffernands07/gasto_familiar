import 'package:flutter/material.dart';

class PlanejamentoCardItem extends StatelessWidget {
  final int index;
  final Map<String, dynamic> evento;
  final bool isDarkMode;
  final VoidCallback onDelete;

  const PlanejamentoCardItem({
    super.key,
    required this.index,
    required this.evento,
    required this.isDarkMode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDarkMode ? Colors.white24 : const Color(0xFFEFEBE4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${evento['titulo']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${(evento['valor'] as double).toStringAsFixed(2).replaceFirst('.', ',')} • ${evento['horas']}h',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
            onPressed: onDelete,
          ),
          const Icon(Icons.drag_handle, size: 20, color: Colors.grey),
        ],
      ),
    );
  }
}
