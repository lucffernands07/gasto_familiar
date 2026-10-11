import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoricoScreen extends StatelessWidget {
  final String familyId;

  const HistoricoScreen({super.key, required this.familyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6EE),
        elevation: 0,
        title: const Text('Histórico de Atividades', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('families')
            .doc(familyId)
            .collection('history')
            .orderBy('createdAt', descending: true) // Mais recente primeiro
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A4A4A)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum histórico registrado ainda.',
                style: TextStyle(color: Color(0xFF666666), fontSize: 16),
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
                  color: const Color(0xFFFFFDF8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEBE4)),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2C3E50)),
                        ),
                        Text(
                          dataFormatada,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detalhes,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Por: $usuario', style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                        Text('Sessão/IP: $ip', style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
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
