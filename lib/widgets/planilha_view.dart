import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanilhaView extends StatelessWidget {
  final String familyId;
  final bool mostrarSaldo;
  final DateTime mesSelecionado; // <- Adicionado

  const PlanilhaView({
    super.key,
    required this.familyId,
    required this.mostrarSaldo,
    required this.mesSelecionado, // <- Adicionado
  });

  Future<void> _registrarHistorico(String acao, String detalhes) async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final nomeDispositivo = prefs.getString('device_nickname') ?? 'Dispositivo Padrão';

    await FirebaseFirestore.instance
        .collection('families')
        .doc(familyId)
        .collection('history')
        .add({
      'acao': acao,
      'detalhes': detalhes,
      'usuario': user?.email ?? 'Usuário',
      'ip': nomeDispositivo,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _mostrarDialogEditarTransacao(BuildContext context, String transId, Map<String, dynamic> dadosAtuais) {
    final db = FirebaseFirestore.instance;
    final descController = TextEditingController(text: dadosAtuais['descricao'] ?? '');
    final valorController = TextEditingController(text: (dadosAtuais['valor'] ?? 0.0).toString());
    final catController = TextEditingController(text: dadosAtuais['categoria'] ?? 'Geral');
    String statusAtual = dadosAtuais['status'] ?? 'Recebido';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFFFAF6EE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Transação', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: catController, decoration: const InputDecoration(labelText: 'Nome da Coluna / Categoria', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: valorController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: ['Recebido', 'Pago', 'Pendente'].contains(statusAtual) ? statusAtual : 'Recebido',
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Recebido', child: Text('Recebido')),
                    DropdownMenuItem(value: 'Pago', child: Text('Pago')),
                    DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                  ],
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => statusAtual = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await db.collection('families').doc(familyId).collection('transactions').doc(transId).delete();
                await _registrarHistorico('Exclusão', 'Transação "${dadosAtuais['descricao']}" excluída');
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final novoValor = double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0;
                final novaDesc = descController.text.trim();
                final novaCat = catController.text.trim();

                if (novoValor > 0) {
                  await db.collection('families').doc(familyId).collection('transactions').doc(transId).update({
                    'categoria': novaCat.isNotEmpty ? novaCat : 'Geral',
                    'descricao': novaDesc.isNotEmpty ? novaDesc : 'Transação',
                    'valor': novoValor,
                    'status': statusAtual,
                  });
                  await _registrarHistorico('Edição', 'Transação "$novaDesc" atualizada ($novoValor - $statusAtual)');
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
              child: const Text('Salvar', style: TextStyle(color: Color(0xFF2C3E50))),
            ),
          ],
        ),
      ),
    );
  }

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

        final Map<String, List<Map<String, dynamic>>> tabelasPorCategoria = {};
        final Map<String, String> tiposPorCategoria = {};

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          
          // Filtrar por mês e ano selecionados
          if (data['createdAt'] != null) {
            final Timestamp timestamp = data['createdAt'];
            final DateTime dataTx = timestamp.toDate();
            if (dataTx.year != mesSelecionado.year || dataTx.month != mesSelecionado.month) {
              continue; // Ignora se não pertencer ao mês selecionado
            }
          }

          final categoria = data['categoria'] ?? 'Geral';
          final tipo = data['tipo'] ?? 'despesa';

          tabelasPorCategoria.putIfAbsent(categoria, () => []);
          tabelasPorCategoria[categoria]!.add({
            'id': doc.id,
            'descricao': data['descricao'] ?? '',
            'valor': (data['valor'] ?? 0.0).toDouble(),
            'status': data['status'] ?? (tipo == 'receita' ? 'Recebido' : 'Pago'),
            'tipo': tipo,
          });
          tiposPorCategoria[categoria] = tipo;
        }

        if (tabelasPorCategoria.isEmpty) {
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
                Icon(Icons.calendar_today_outlined, size: 48, color: Color(0xFF888888)),
                SizedBox(height: 12),
                Text('Nenhuma transação neste mês', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                SizedBox(height: 6),
                Text('Altere o mês no topo ou clique em "+ Lançar".', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
              ],
            ),
          );
        }

        return Column(
          children: tabelasPorCategoria.entries.map((entry) {
            final categoria = entry.key;
            final itens = entry.value;
            final tipo = tiposPorCategoria[categoria] ?? 'despesa';
            final isReceita = tipo == 'receita';

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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: corHeader,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            categoria.toUpperCase(),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: corTextoHeader, letterSpacing: 0.5),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'VALOR R\$',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: corTextoHeader),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'STATUS',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: corTextoHeader),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...itens.map((item) => InkWell(
                        onTap: () => _mostrarDialogEditarTransacao(context, item['id'], {
                          'categoria': categoria,
                          'descricao': item['descricao'],
                          'valor': item['valor'],
                          'status': item['status'],
                          'tipo': item['tipo'],
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  mostrarSaldo ? (item['valor'] as double).toStringAsFixed(2).replaceFirst('.', ',') : '•••',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF222222)),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  item['status'],
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
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
                          mostrarSaldo ? totalCategoria.toStringAsFixed(2).replaceFirst('.', ',') : '•••',
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
