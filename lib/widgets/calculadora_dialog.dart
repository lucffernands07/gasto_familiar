import 'package:flutter/material.dart';

class CalculadoraDialog extends StatefulWidget {
  final TextEditingController valorController;
  final bool isDarkMode;

  const CalculadoraDialog({
    super.key,
    required this.valorController,
    required this.isDarkMode,
  });

  static void mostrar(BuildContext context, TextEditingController valorController, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => CalculadoraDialog(
        valorController: valorController,
        isDarkMode: isDarkMode,
      ),
    );
  }

  @override
  State<CalculadoraDialog> createState() => _CalculadoraDialogState();
}

class _CalculadoraDialogState extends State<CalculadoraDialog> {
  late final TextEditingController _calcController;

  @override
  void initState() {
    super.initState();
    _calcController = TextEditingController(text: widget.valorController.text);
  }

  @override
  void dispose() {
    _calcController.dispose();
    super.dispose();
  }

  void _adicionarOperador(String op) {
    _calcController.text += ' $op ';
    _calcController.selection = TextSelection.fromPosition(TextPosition(offset: _calcController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF6EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.calculate, color: widget.isDarkMode ? Colors.white : const Color(0xFF2C3E50)),
          const SizedBox(width: 8),
          Text(
            'Calculadora Rápida',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _calcController,
            autofocus: true,
            keyboardType: TextInputType.text,
            style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              labelText: 'Digite a conta',
              hintText: 'Ex: 50 + 30',
              labelStyle: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBotaoOperador('+'),
              _buildBotaoOperador('-'),
              _buildBotaoOperador('*'),
              _buildBotaoOperador('/'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final texto = _calcController.text.replaceAll(',', '.');
            double resultado = 0.0;
            try {
              if (texto.contains('+')) {
                final partes = texto.split('+');
                resultado = partes.fold(0.0, (sum, p) => sum + (double.tryParse(p.trim()) ?? 0.0));
              } else if (texto.contains('-')) {
                final partes = texto.split('-');
                resultado = (double.tryParse(partes[0].trim()) ?? 0.0) - (double.tryParse(partes[1].trim()) ?? 0.0);
              } else {
                resultado = double.tryParse(texto) ?? 0.0;
              }
            } catch (_) {
              resultado = double.tryParse(texto) ?? 0.0;
            }

            if (resultado > 0) {
              widget.valorController.text = resultado.toStringAsFixed(2).replaceFirst('.', ',');
            }
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
          child: const Text('Usar Valor', style: TextStyle(color: Color(0xFF2C3E50))),
        ),
      ],
    );
  }

  Widget _buildBotaoOperador(String op) {
    return InkWell(
      onTap: () => _adicionarOperador(op),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFD4E6F1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(op, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
      ),
    );
  }
}
