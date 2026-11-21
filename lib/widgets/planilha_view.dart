import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculadora_dialog.dart';
import 'copiar_planilhas_sheet.dart';

class PlanilhaView extends StatelessWidget {
  final String familyId;
  final bool mostrarSaldo;
  final DateTime mesSelecionado;
  final VoidCallback? onIrParaMesAnterior;

  const PlanilhaView({
    super.key,
    required this.familyId,
    required this.mostrarSaldo,
    required this.mesSelecionado,
    this.onIrParaMesAnterior,
  });

  Widget _buildBotaoCopiar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFCBDD), Color(0xFFFFF3E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => CopiarPlanilhasSheet.abrir(
          context: context,
          familyId: familyId,
          mesSelecionado: mesSelecionado,
          onIrParaMesAnterior: onIrParaMesAnterior,
        ),
        icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF333333)),
        label: const Text(
          'Copiar transações do mês anterior',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

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

  void _mostrarDialogEditarTransacao(
    BuildContext context,
    String transId,
    Map<String, dynamic> dadosAtuais,
  ) {
    final db = FirebaseFirestore.instance;
    final descController = TextEditingController(text: dadosAtuais['descricao'] ?? '');
    final valorController = TextEditingController(
      text: (dadosAtuais['valor'] ?? 0.0).toString().replaceFirst('.', ','),
    );
    final catController = TextEditingController(text: dadosAtuais['categoria'] ?? 'Geral');
    String statusAtual = dadosAtuais['status'] ?? 'Recebido';
    bool isValeAtual = (dadosAtuais['isVale'] == true) || (statusAtual == 'Vale');
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFFFAF6EE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Editar Transação', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFCBDD),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.calculate_outlined, color: Color(0xFF2C3E50), size: 22),
                  tooltip: 'Calculadora',
                  onPressed: () => CalculadoraDialog.mostrar(context, valorController, isDarkMode),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: catController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Coluna / Categoria',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: ['Recebido', 'Pago', 'Pendente', 'Vale'].contains(statusAtual)
                      ? statusAtual
                      : 'Recebido',
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Recebido', child: Text('Recebido')),
                    DropdownMenuItem(value: 'Pago', child: Text('Pago')),
                    DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                    DropdownMenuItem(value: 'Vale', child: Text('Vale')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setStateDialog(() {
                        statusAtual = val;
                        if (val == 'Vale') isValeAtual = true;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Incluir no cálculo de Vale', style: TextStyle(fontSize: 14)),
                  value: isValeAtual,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => isValeAtual = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await db
                    .collection('families')
                    .doc(familyId)
                    .collection('transactions')
                    .doc(transId)
                    .delete();
                await _registrarHistorico(
                  'Exclusão',
                  'Transação "${dadosAtuais['descricao']}" excluída',
                );
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
                  await db
                      .collection('families')
                      .doc(familyId)
                      .collection('transactions')
                      .doc(transId)
                      .update({
                    'categoria': novaCat.isNotEmpty ? novaCat : 'Geral',
                    'descricao': novaDesc.isNotEmpty ? novaDesc : 'Transação',
                    'valor': novoValor,
                    'status': statusAtual,
                    'isVale': statusAtual == 'Vale' ? true : isValeAtual,
                  });
                  await _registrarHistorico(
                    'Edição',
                    'Transação "$novaDesc" atualizada ($novoValor - $statusAtual)',
                  );
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

  Widget _buildCardVazio(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      child: Column(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 48, color: Color(0xFF888888)),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma transação neste mês',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Altere o mês no topo ou clique em "+ Lançar".',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFEFEBE4)),
          const SizedBox(height: 14),
          _buildBotaoCopiar(context),
        ],
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
          return _buildCardVazio(context);
        }

        final Map<String, List> tabelasPorCategoria = {};
        final Map<String, String> tiposPorCategoria = {};

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (data['createdAt'] != null) {
            final Timestamp timestamp = data['createdAt'];
            final DateTime dataTx = timestamp.toDate();
            if (dataTx.year != mesSelecionado.year || dataTx.month != mesSelecionado.month) {
              continue;
            }
          }

          final categoria = (data['categoria'] ?? 'Geral').toString();
          final tipo = (data['tipo'] ?? 'despesa').toString();
          final status = (data['status'] ?? (tipo == 'receita' ? 'Recebido' : 'Pago')).toString();

          tabelasPorCategoria.putIfAbsent(categoria, () => []);
          tabelasPorCategoria[categoria]!.add({
            'id': doc.id,
            'descricao': (data['descricao'] ?? '').toString(),
            'valor': (data['valor'] ?? 0.0).toDouble(),
            'status': status,
            'isVale': (data['isVale'] == true) || (status == 'Vale'),
            'tipo': tipo,
          });
          tiposPorCategoria[categoria] = tipo;
        }

        if (tabelasPorCategoria.isEmpty) {
          return _buildCardVazio(context);
        }

        final sortedKeys = tabelasPorCategoria.keys.toList()
          ..sort((a, b) {
            final tipoA = tiposPorCategoria[a] ?? 'despesa';
            final tipoB = tiposPorCategoria[b] ?? 'despesa';
            if (tipoA == 'receita' && tipoB != 'receita') return -1;
            if (tipoA != 'receita' && tipoB == 'receita') return 1;
            return a.compareTo(b);
          });

        return Column(
          children: [
            ...sortedKeys.map((categoria) {
              final itens = tabelasPorCategoria[categoria]!;

              itens.sort((a, b) {
                int peso(String s) {
                  if (s == 'Pago' || s == 'Recebido') return 1;
                  if (s == 'Pendente') return 2;
                  if (s == 'Vale') return 3;
                  return 2;
                }
                return peso(a['status']).compareTo(peso(b['status']));
              });

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
                  border: Border.all(color: Colors.white, width: 1.0),
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
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: corTextoHeader,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'VALOR R\$',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: corTextoHeader,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'STATUS',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: corTextoHeader,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...itens.map((item) {
                      final status = item['status'].toString();
                      final bool isVale = item['isVale'] == true;

                      Color corStatus;
                      if (isVale || status == 'Vale') {
                        corStatus = Colors.purple;
                      } else if (status == 'Pago' || status == 'Recebido') {
                        corStatus = Colors.green;
                      } else {
                        corStatus = Colors.red;
                      }

                      return InkWell(
                        onTap: () => _mostrarDialogEditarTransacao(context, item['id'].toString(), {
                          'categoria': categoria,
                          'descricao': item['descricao'],
                          'valor': item['valor'],
                          'status': status,
                          'isVale': isVale,
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
                                  item['descricao'].toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  mostrarSaldo
                                      ? (item['valor'] as double).toStringAsFixed(2).replaceFirst('.', ',')
                                      : '•••',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  status,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: corStatus,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          Text(
                            mostrarSaldo
                                ? totalCategoria.toStringAsFixed(2).replaceFirst('.', ',')
                                : '•••',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            _buildBotaoCopiar(context),
          ],
        );
      },
    );
  }
}
