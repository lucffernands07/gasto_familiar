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

  // Converte qualquer formato de horas (decimal, string com vírgula ou int) para o formato '08:00h'
  String _formatarHoras(dynamic horasInput) {
    double h = 0.0;
    if (horasInput is int) {
      h = horasInput.toDouble();
    } else if (horasInput is double) {
      h = horasInput;
    } else if (horasInput is String) {
      h = double.tryParse(horasInput.replaceAll(',', '.').replaceAll('h', '').trim()) ?? 0.0;
    }

    int horas = h.floor();
    int minutos = ((h - horas) * 60).round();
    return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}h';
  }

  void _mostrarNota(BuildContext context, String nota) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF3E0), Color(0xFFFAF6EE)], // Degradê suave de amarelo claro para branco/bege da app
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFFD4AC0D), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Notas / Observações',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                nota,
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCBDD), // Rosa suave do tema
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nota = evento['nota'] ?? '';
    final bool temNota = nota.trim().isNotEmpty;
    final String duracaoFormatada = _formatarHoras(evento['horas']);
    
    final dynamic valorRaw = evento['valor'];
    final double valor = valorRaw is double 
        ? valorRaw 
        : (valorRaw is int 
            ? valorRaw.toDouble() 
            : double.tryParse(valorRaw.toString().replaceAll(',', '.')) ?? 0.0);

    return Stack(
      children: [
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
                        'R\$ ${valor.toStringAsFixed(2).replaceFirst('.', ',')} • $duracaoFormatada',
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
        ),
        // Indicador de Nota (Círculo amarelo com exclamação preta) no canto superior direito
        if (temNota)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _mostrarNota(context, nota),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high_rounded,
                  size: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
