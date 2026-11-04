import 'package:flutter/material.dart';

class PlanejamentoCardItem extends StatelessWidget {
  final int index;
  final Map<String, dynamic> evento;
  final bool isDarkMode;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PlanejamentoCardItem({
    super.key,
    required this.index,
    required this.evento,
    required this.isDarkMode,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit, // Permite clicar no card para editar
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Degradê rosa para laranja nos cartões
          gradient: const LinearGradient(
            colors: [Color(0xFFFFCBDD), Color(0xFFFFF3E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFEBE4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFF2C3E50) : const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'R\$ ${(evento['valor'] as double).toStringAsFixed(2).replaceFirst('.', ',')} • ${evento['horas'].toStringAsFixed(1).replaceFirst('.', ',')}h',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? const Color(0xFF444444) : const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2C3E50)),
              onPressed: onEdit,
              tooltip: 'Editar Item',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              onPressed: onDelete,
              tooltip: 'Excluir Item',
            ),
            const Icon(Icons.drag_handle, size: 20, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
