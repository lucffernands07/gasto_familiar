import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanilhaView extends StatelessWidget {
  final String familyId;
  final bool mostrarSaldo;

  const PlanilhaView({
    super.key,
    required this.familyId,
    required this.mostrarSaldo,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('families')
          .doc(familyId)
          .collection('transactions')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF4A4A4A))),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEFEBE4)),
            ),
            child: const Column(
              children: [
                Icon(Icons.table_chart_outlined, size: 48, color: Color(0xFF888888)),
                SizedBox(height: 12),
                Text('Nenhuma transação lançada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                SizedBox(height: 6),
                Text('Clique em "+ Lançar" para adicionar receitas ou despesas.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
              ],
            ),
          );
        }

        // Agrupar transações por categoria
        final Map<String, List<Map<String, dynamic>>> tabelasPorCategoria = {};
        final Map<String, String> tiposPorCategoria = {};

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final categoria = data['categoria'] ?? 'Geral';
          final tipo = data['tipo'] ?? 'despesa';

          tabelasPorCategoria.putIfAbsent(categoria, () => []);
          tabelasPorCategoria[categoria]!.add({
            'id': doc.id,
            'descricao': data['descricao'] ?? '',
            'valor': (data['valor'] ?? 0.0).toDouble(),
            'status': data['status'] ?? (tipo == 'receita' ? 'Recebido' : 'Pago'),
          });
          tiposPorCategoria[categoria] = tipo;
        }

        return Column(
          children: tabelasPorCategoria.entries.map((entry) {
            final categoria = entry.key;
            final itens = entry.value;
            final tipo = tiposPorCategoria[categoria] ?? 'despesa';
            final isReceita = tipo == 'receita';

            // Cor de cabeçalho: verde para receita, vermelho para despesa
            final Color corHeader = isReceita ? const Color(0xFFA8E6CF) : const Color(0xFFFF8B94);
            final Color corTextoHeader = isReceita ? const Color(0xFF1B4D3E) : const Color(0xFF5C1D24);

            double totalCategoria = itens.fold(0.0, (sum, item) => sum + (item['valor'] as double));

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFEBE4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabeçalho da Tabela
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: corHeader,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          categoria.toUpperCase(),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: corTextoHeader, letterSpacing: 0.5),
                        ),
                        Text(
                          'R\$',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: corTextoHeader),
                        ),
                        Text(
                          'STATUS',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: corTextoHeader),
                        ),
                      ],
                    ),
                  ),
                  // Linhas de Itens
                  ...itens.map((item) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFF4F0E6))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                item['descricao'],
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                mostrarSaldo ? 'R\$ ${(item['valor'] as double).toStringAsFixed(2).replaceFirst('.', ',')}' : 'R\$ •••',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF222222)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: item['status'] == 'Recebido' || item['status'] == 'Pago'
                                    ? const Color(0xFFE8F8F5)
                                    : const Color(0xFFFEF9E7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['status'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: item['status'] == 'Recebido' || item['status'] == 'Pago'
                                      .toString()
                                      .contains('true') // fallback
                                      ? const Color(0xFF117A65)
                                      : const Color(0xFF7D6608),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  // Linha de Total
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFEBE4),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                        ),
                        Text(
                          mostrarSaldo ? 'R\$ ${totalCategoria.toStringAsFixed(2).replaceFirst('.', ',')}' : 'R\$ •••',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
