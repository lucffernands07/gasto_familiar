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
  String _tituloPlaneamento = 'Meu Planeamento';
  final TextEditingController _tituloController = TextEditingController();
  bool _isLoading = true;

  List _eventos = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final doc = await _service.carregarPlaneamento(widget.familyId);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _tituloPlaneamento = data['titulo'] ?? 'Meu Planeamento';
          _eventos = List.from(data['eventos'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarDados() async {
    await _service.salvarPlaneamento(widget.familyId, _tituloPlaneamento, _eventos);
  }

  String _formatarHorasTotais(double totalHoras) {
    int horas = totalHoras.floor();
    int minutos = ((totalHoras - horas) * 60).round();
    return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}h';
  }

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
              _salvarDados();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            child: const Text('Salvar', style: TextStyle(color: Color(0xFF2C3E50))),
          ),
        ],
      ),
    );
  }

  void _abrirModalItem({int? indexEditando}) {
    final isEditando = indexEditando != null;
    final eventoAtual = isEditando ? _eventos[indexEditando] : null;

    final tituloController = TextEditingController(text: isEditando ? eventoAtual['titulo'] : '');
    final valorController = TextEditingController(text: isEditando ? eventoAtual['valor'].toString().replaceFirst('.', ',') : '');
    final horasController = TextEditingController(text: isEditando ? eventoAtual['horas'].toString().replaceFirst('.', ',') : '');
    final notaController = TextEditingController(text: isEditando ? (eventoAtual['nota'] ?? '') : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF6EE),
        title: Text(isEditando ? 'Editar Etapa / Serviço' : 'Adicionar Etapa / Serviço', style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
                decoration: const InputDecoration(labelText: 'Descrição (Ex: Buffet, Bolo...)', border: OutlineInputBorder()),
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
                decoration: const InputDecoration(labelText: 'Duração (Horas)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notaController,
                maxLines: 3,
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
                decoration: const InputDecoration(labelText: 'Notas / Observações', border: OutlineInputBorder()),
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
              final nota = notaController.text.trim();

              if (desc.isNotEmpty) {
                setState(() {
                  if (isEditando) {
                    _eventos[indexEditando] = {'titulo': desc, 'valor': val, 'horas': hrs, 'nota': nota};
                  } else {
                    _eventos.add({'titulo': desc, 'valor': val, 'horas': hrs, 'nota': nota});
                  }
                });
                _salvarDados();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            child: Text(isEditando ? 'Atualizar' : 'Adicionar', style: const TextStyle(color: Color(0xFF2C3E50))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalGeral = _eventos.fold(0.0, (sum, item) => sum + (item['valor'] is double ? item['valor'] : double.tryParse(item['valor'].toString().replaceAll(',', '.')) ?? 0.0));
    double totalHoras = _eventos.fold(0.0, (sum, item) => sum + (item['horas'] is double ? item['horas'] : double.tryParse(item['horas'].toString().replaceAll(',', '.')) ?? 0.0));

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
      // Botão + movido para o canto inferior direito conforme solicitado
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFCBDD), Color(0xFFD4E6F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _abrirModalItem(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Color(0xFF2C3E50), size: 28),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                          const Text('DURAÇÃO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
                          const SizedBox(height: 4),
                          Text(_formatarHorasTotais(totalHoras), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      'Etapas do Planeamento',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode ? Colors.white : const Color(0xFF333333),
                      ),
                    ),
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
                            _salvarDados();
                          },
                          itemBuilder: (context, index) {
                            final evento = _eventos[index];
                            bool isEven = index % 2 == 0;

                            return Column(
                              key: ValueKey(evento),
                              children: [
                                Row(
                                  children: [
                                    if (!isEven) const Expanded(flex: 1, child: SizedBox(width: 20)),
                                    Expanded(
                                      flex: 3,
                                      child: PlanejamentoCardItem(
                                        index: index,
                                        evento: evento,
                                        isDarkMode: widget.isDarkMode,
                                        onEdit: () => _abrirModalItem(indexEditando: index),
                                        onDelete: () {
                                          setState(() {
                                            _eventos.removeAt(index);
                                          });
                                          _salvarDados();
                                        },
                                      ),
                                    ),
                                    if (isEven) const Expanded(flex: 1, child: SizedBox(width: 20)),
                                  ],
                                ),
                                if (index < _eventos.length - 1)
                                  SizedBox(
                                    height: 32,
                                    child: CustomPaint(
                                      painter: SnakeCurvePainter(isNextEven: (index + 1) % 2 == 0),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class SnakeCurvePainter extends CustomPainter {
  final bool isNextEven;

  SnakeCurvePainter({required this.isNextEven});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9B59B6)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    double targetX = isNextEven ? size.width * 0.35 : size.width * 0.65;
    path.cubicTo(
      size.width / 2, size.height * 0.5,
      targetX, size.height * 0.5,
      targetX, size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
