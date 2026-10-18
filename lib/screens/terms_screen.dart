import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  final bool isDarkMode;

  const TermsScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAF6EE);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Termos de Uso', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Termos e Condições de Uso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                'Última atualização: Outubro de 2026',
                style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white70 : Colors.grey[600]),
              ),
              const Divider(height: 24),
              _buildSecao(
                '1. Aceitação dos Termos',
                'Ao aceder ou utilizar a aplicação Gasto Familiar, concorda em cumprir estes Termos de Uso e todas as leis e regulamentos aplicáveis.',
                textColor,
              ),
              _buildSecao(
                '2. Registo e Conta',
                'Para utilizar as funcionalidades de sincronização, é necessário efetuar autenticação via Google. É responsável por manter a confidencialidade das informações da sua conta e grupo familiar.',
                textColor,
              ),
              _buildSecao(
                '3. Uso Aceitável',
                'A aplicação destina-se exclusivamente ao controlo financeiro pessoal e familiar. Compromete-se a não utilizar a plataforma para quaisquer fins ilícitos ou não autorizados.',
                textColor,
              ),
              _buildSecao(
                '4. Modificações e Disponibilidade',
                'Reservamo-nos o direito de modificar, suspender ou encerrar a aplicação ou os seus recursos a qualquer momento, sem aviso prévio.',
                textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecao(String titulo, String descricao, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
          const SizedBox(height: 4),
          Text(descricao, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.8), height: 1.4)),
        ],
      ),
    );
  }
}
