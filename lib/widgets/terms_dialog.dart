import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsDialog {
  static Future<void> verificarEExibir(BuildContext context, bool isDarkMode, VoidCallback onAccepted) async {
    final prefs = await SharedPreferences.getInstance();
    final termosAceites = prefs.getBool('terms_accepted') ?? false;

    if (!termosAceites && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _TermsDialogContent(
          isDarkMode: isDarkMode,
          onAccepted: onAccepted,
        ),
      );
    }
  }
}

class _TermsDialogContent extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onAccepted;

  const _TermsDialogContent({required this.isDarkMode, required this.onAccepted});

  @override
  State<_TermsDialogContent> createState() => _TermsDialogContentState();
}

class _TermsDialogContentState extends State<_TermsDialogContent> {
  bool _chegouAoFim = false;
  bool _concordou = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 20) {
        if (!_chegouAoFim) {
          setState(() {
            _chegouAoFim = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF6EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Termos de Uso e Privacidade',
        style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black87),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Por favor, leia atentamente todo o termo abaixo para continuar:',
              style: TextStyle(fontSize: 12, color: widget.isDarkMode ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.black26 : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(
                    '1. ACEITAÇÃO DOS TERMOS\n'
                    'Ao aceder ou utilizar a aplicação Gasto Familiar, concorda em cumprir estes Termos de Uso, bem como a nossa Política de Privacidade.\n\n'
                    '2. REGISTO E CONTA\n'
                    'Para utilizar as funcionalidades de sincronização financeira, é necessário efetuar autenticação via Google. O utilizador é inteiramente responsável por manter a confidencialidade das informações da sua conta e grupo familiar.\n\n'
                    '3. USO ACEITÁVEL\n'
                    'A aplicação destina-se exclusivamente ao controlo financeiro pessoal e familiar. Compromete-se a não utilizar a plataforma para quaisquer fins ilícitos, fraudulentos ou não autorizados.\n\n'
                    '4. PRIVACIDADE E DADOS\n'
                    'Os seus dados financeiros são armazenados de forma segura e encriptada através dos serviços do Firebase. Não partilhamos as suas informações financeiras com terceiros.\n\n'
                    '5. MODIFICAÇÕES E DISPONIBILIDADE\n'
                    'Reservamo-nos o direito de modificar, suspender ou encerrar a aplicação ou os seus recursos a qualquer momento, sem aviso prévio. Obrigado por utilizar o Gasto Familiar.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!_chegouAoFim)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.arrow_downward, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Role até ao final para poder aceitar',
                    style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFFA8E6CF),
              checkColor: const Color(0xFF2C3E50),
              enabled: _chegouAoFim && !_concordou,
              title: Text(
                'Li e concordo com os Termos de Uso e Política de Privacidade',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _chegouAoFim ? (widget.isDarkMode ? Colors.white : Colors.black87) : Colors.grey,
                ),
              ),
              value: _concordou,
              onChanged: (_chegouAoFim && !_concordou)
                  ? (bool? value) {
                      if (value == true) {
                        setState(() {
                          _concordou = true;
                        });
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: (_chegouAoFim && _concordou)
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('terms_accepted', true);
                  if (context.mounted) {
                    Navigator.pop(context);
                    widget.onAccepted();
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA8E6CF),
            disabledBackgroundColor: Colors.grey.withOpacity(0.3),
          ),
          child: const Text('Continuar', style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
