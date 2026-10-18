import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  final bool isDarkMode;

  const PrivacyScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAF6EE);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Política de Privacidade', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
                'Política de Privacidade - Gasto Familiar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                'Última atualização: Outubro de 2026',
                style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white70 : Colors.grey[600]),
              ),
              const Divider(height: 24),
              _buildSecao(
                '1. Informações que Recolhemos',
                'A nossa aplicação recolhe o seu endereço de e-mail e nome através do Google Sign-In exclusivamente para autenticação, além dos dados de transações e despesas introduzidos por si para o controlo financeiro familiar.',
                textColor,
              ),
              _buildSecao(
                '2. Uso das Informações',
                'Os dados financeiros são armazenados de forma segura e sincronizados apenas com os membros da família autorizados. Não partilhamos as suas informações com terceiros.',
                textColor,
              ),
              _buildSecao(
                '3. Segurança dos Dados',
                'Utilizamos a infraestrutura segura do Firebase (Google Cloud) para encriptação e proteção de todos os dados registados.',
                textColor,
              ),
              _buildSecao(
                '4. Exclusão de Contas e Dados',
                'Pode solicitar a eliminação dos seus dados a qualquer momento entrando em contacto com o suporte ou através das definições da conta.',
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
