import 'package:flutter/material.dart';
import '../widgets/planejamento_card_item.dart';
import '../services/planejamento_service.dart';

class PlanejarScreen extends StatefulWidget {
  final String familyId;
  final bool isDarkMode;

  const PlanejarScreen({
    super.key,
    required this.familyId,
    required this.isDarkMode,
  });

  @override
  State<PlanejarScreen> createState() => _PlanejarScreenState();
}

class _PlanejarScreenState extends State<PlanejarScreen> {
  final PlanejamentoService _service = PlanejamentoService();
  String _tituloPlaneamento = 'Passeio Thermas São Pedro';
  final TextEditingController _tituloController = TextEditingController();

  // Lista tipada corretamente para evitar erros de compilação no Web
  final List _eventos = [
    {'titulo': 'Hotel / Hospedagem', 'valor': 450.0, 'horas': 2.0},
    {'titulo': 'Ingressos Parque', 'valor': 240.0, 'horas': 5.0},
    {'titulo': 'Combustível / Pedágios (Ida e Volta)', 'valor': 180.0, 'horas': 3.5},
  ];

  void _editarTitulo() {
    _tituloController.text = _tituloPlaneamento;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF6EE),
        title: Text('Editar Título', style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87)),
        content: TextField(
          controller: _tituloController,
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Nome do Planeamento'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_tituloController.text.trim().isNotEmpty) {
                  _tituloPlaneamento = _tituloController.text.trim();
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            child: const Text('Salvar', style: TextStyle(color: Color(0xFF2C3E50))),
          ),
        ],
      ),
    );
  }

  void _adicionarEventoModal() {
    final tituloController = TextEditingController();
    final valorController = TextEditingController();
    final horasController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF6EE),
        title: Text('Adicionar Etapa / Serviço', style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
                decoration: const InputDecoration(labelText: 'Descrição (Ex: Almoço, Uber...)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
                decoration: const InputDecoration(labelText: 'Valor (R\$)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: horasController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
                decoration: const InputDecoration(labelText: 'Tempo / Duração (Horas)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0;
              final hrs = double.tryParse(horasController.text.replaceAll(',', '.')) ?? 0.0;
              final desc = tituloController.text.trim();

              if (desc.isNotEmpty) {
                setState(() {
                  _eventos.add({'titulo': desc, 'valor': val, 'horas': hrs});
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            child: const Text('Adicionar', style: TextStyle(color: Color(0xFF2C3E50))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalGeral = _eventos.fold(0.0, (sum, item) => sum + (item['valor'] as double));
    double totalHoras = _eventos.fold(0.0, (sum, item) => sum + (item['horas'] as double));

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAF6EE),
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF6EE),
        elevation: 0,
        iconTheme: IconThemeData(color: widget.isDarkMode ? Colors.white : Colors.black87),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _tituloPlaneamento,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: _editarTitulo,
              tooltip: 'Editar Título',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFCBDD), Color(0xFFFFF3E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('TOTAL PREVISTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
                    const SizedBox(height: 4),
                    Text('R\$ ${totalGeral.toStringAsFixed(2).replaceFirst('.', ',')}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.black26),
                Column(
                  children: [
                    const Text('TEMPO TOTAL / VIAGEM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
                    const SizedBox(height: 4),
                    Text('${totalHoras.toStringAsFixed(1).replaceFirst('.', ',')} h', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Itinerário (Arraste para ordenar)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white70 : Colors.black54)),
                TextButton.icon(
                  onPressed: _adicionarEventoModal,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Novo Item'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _eventos.isEmpty
                ? Center(child: Text('Nenhum evento planeado.', style: TextStyle(color: widget.isDarkMode ? Colors.white60 : Colors.black54)))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _eventos.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = _eventos.removeAt(oldIndex);
                        _eventos.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final evento = _eventos[index];
                      bool isEven = index % 2 == 0;

                      return Container(
                        key: ValueKey(evento),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            if (!isEven) const Expanded(flex: 1, child: SizedBox()),
                            Expanded(
                              flex: 3,
                              child: PlanejamentoCardItem(
                                index: index,
                                evento: evento,
                                isDarkMode: widget.isDarkMode,
                                onDelete: () {
                                  setState(() {
                                    _eventos.removeAt(index);
                                  });
                                },
                              ),
                            ),
                            if (isEven) const Expanded(flex: 1, child: SizedBox()),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
