import 'package:flutter/material.dart';

class PlanejamentoCardItem extends StatelessWidget {
  final int index;
  final Map<String, dynamic> evento;
  final bool isDarkMode;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Function(List novasNotas)? onUpdateNotas;

  const PlanejamentoCardItem({
    super.key,
    required this.index,
    required this.evento,
    required this.isDarkMode,
    required this.onDelete,
    required this.onEdit,
    this.onUpdateNotas,
  });

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

  List _obterListaNotas() {
    final rawNota = evento['nota'];
    if (rawNota is List) {
      return rawNota.map((item) {
        if (item is Map) {
          return {
            'texto': item['texto']?.toString() ?? '',
            'checked': item['checked'] == true,
          };
        }
        return {'texto': item.toString(), 'checked': false};
      }).toList();
    } else if (rawNota is String && rawNota.trim().isNotEmpty) {
      return rawNota.split('\n').where((s) => s.trim().isNotEmpty).map((s) {
        String limpo = s.replaceAll(RegExp(r'^[-*•]\s*'), '').trim();
        return {'texto': limpo, 'checked': false};
      }).toList();
    }
    return [];
  }

  void _mostrarNota(BuildContext context) {
    List notasList = _obterListaNotas();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFAF6EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.5),
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
                    Icon(Icons.info_outline, color: Color(0xFF555555), size: 22),
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
                if (notasList.isEmpty)
                  const Text('Nenhuma nota registada.', style: TextStyle(color: Colors.black54, fontSize: 14))
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: notasList.length,
                      itemBuilder: (context, idx) {
                        final notaItem = notasList[idx];
                        bool isChecked = notaItem['checked'] == true;
                        return CheckboxListTile(
                          value: isChecked,
                          activeColor: const Color(0xFF555555),
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            notaItem['texto'],
                            style: TextStyle(
                              color: isChecked ? Colors.grey : const Color(0xFF333333),
                              fontSize: 14,
                              decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                          onChanged: (bool? val) {
                            setStateDialog(() {
                              notasList[idx]['checked'] = val ?? false;
                            });
                            if (onUpdateNotas != null) {
                              onUpdateNotas!(notasList);
                            }
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFD4E6F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Editar',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCBDD),
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notasList = _obterListaNotas();
    final bool temNota = notasList.isNotEmpty;
    final String duracaoFormatada = _formatarHoras(evento['horas']);
    
    final dynamic valorRaw = evento['valor'];
    final double valor = valorRaw is double 
        ? valorRaw 
        : (valorRaw is int 
            ? valorRaw.toDouble() 
            : double.tryParse(valorRaw.toString().replaceAll(',', '.')) ?? 0.0);

    // Recupera o status (padrão Pendente se não houver)
    final String status = evento['status'] ?? 'Pendente';
    
    // Cores e estilo baseados no status
    Color statusBgColor;
    Color statusTextColor;
    if (status == 'Pago' || status == 'Concluído') {
      statusBgColor = Colors.green.shade100;
      statusTextColor = Colors.green.shade800;
    } else {
      statusBgColor = Colors.red.shade100;
      statusTextColor = Colors.red.shade800;
    }

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
                      const SizedBox(height: 8),
                      // Etiqueta de Status arredondada abaixo do valor e horas
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusTextColor,
                          ),
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
        if (temNota)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _mostrarNota(context),
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
