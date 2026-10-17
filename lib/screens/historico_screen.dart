import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoricoScreen extends StatelessWidget {
  final String familyId;
  final bool isDarkMode;

  const HistoricoScreen({super.key, required this.familyId, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAF6EE);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFDF8);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final Color subtitleColor = isDarkMode ? Colors.white70 : const Color(0xFF666666);
    final Color borderColor = isDarkMode ? Colors.white24 : const Color(0xFFEFEBE4);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF6EE),
        elevation: 0,
        title: Text('Histórico de Atividades', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('families')
            .doc(familyId)
            .collection('history')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: textColor));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nenhum histórico registrado ainda.',
                style: TextStyle(color: subtitleColor, fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final acao = data['acao'] ?? 'Ação';
              final detalhes = data['detalhes'] ?? '';
              final usuario = data['usuario'] ?? 'Usuário';
              final ip = data['ip'] ?? 'IP Local';
              final timestamp = data['createdAt'] as Timestamp?;
              final dataFormatada = timestamp != null
                  ? DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp.toDate())
                  : 'Data recente';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          acao,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDarkMode ? Colors.lightBlueAccent : const Color(0xFF2C3E50)),
                        ),
                        Text(
                          dataFormatada,
                          style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white60 : const Color(0xFF888888)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detalhes,
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Por: $usuario', style: TextStyle(fontSize: 11, color: subtitleColor)),
                        Text('Sessão/IP: $ip', style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white60 : const Color(0xFF888888))),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
