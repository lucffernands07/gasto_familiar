import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CopiarPlanilhasSheet {
  static String _formatarMes(DateTime data) {
    final mes = data.month.toString().padLeft(2, '0');
    return '$mes/${data.year}';
  }

  static Future<void> _registrarHistorico({
    required String familyId,
    required String acao,
    required String detalhes,
  }) async {
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

  static Future<void> _executarCopiaCategorias({
    required BuildContext context,
    required String familyId,
    required DateTime mesDestino,
    required Map<String, List>> transacoesPorCategoria,
    required Set<String> categoriasSelecionadas,
  }) async {
    if (categoriasSelecionadas.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione pelo menos uma planilha para copiar!')),
        );
      }
      return;
    }

    final db = FirebaseFirestore.instance;

    try {
      int totalCopiadas = 0;
      final agora = DateTime.now();
      final ultimoDiaDoMesDestino = DateTime(mesDestino.year, mesDestino.month + 1, 0).day;
      final diaApropriado = agora.day > ultimoDiaDoMesDestino ? ultimoDiaDoMesDestino : agora.day;

      final novaData = DateTime(
        mesDestino.year,
        mesDestino.month,
        diaApropriado,
        agora.hour,
        agora.minute,
        agora.second,
      );

      for (final categoria in categoriasSelecionadas) {
        final listaDocs = transacoesPorCategoria[categoria] ?? [];
        for (final data in listaDocs) {
          final novaId = db.collection('families').doc(familyId).collection('transactions').doc().id;
          await db.collection('families').doc(familyId).collection('transactions').doc(novaId).set({
            'categoria': data['categoria'] ?? 'Geral',
            'descricao': data['descricao'] ?? '',
            'valor': data['valor'] ?? 0.0,
            'tipo': data['tipo'] ?? 'despesa',
            'status': 'Pendente',
            'isVale': data['isVale'] == true,
            'createdAt': Timestamp.fromDate(novaData),
          });
          totalCopiadas++;
        }
      }

      await _registrarHistorico(
        familyId: familyId,
        acao: 'Cópia',
        detalhes:
            'Planilhas [${categoriasSelecionadas.join(', ')}] ($totalCopiadas transações) copiadas para ${_formatarMes(mesDestino)} como Pendentes',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$totalCopiadas transação(ões) de ${categoriasSelecionadas.length} planilha(s) copiada(s) como Pendentes!',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao copiar transações: $e')),
        );
      }
    }
  }

  static Future<void> abrir({
    required BuildContext context,
    required String familyId,
    required DateTime mesSelecionado,
    VoidCallback? onIrParaMesAnterior,
  }) async {
    final db = FirebaseFirestore.instance;
    final DateTime mesDestino = mesSelecionado;
    final DateTime mesAnterior = DateTime(mesSelecionado.year, mesSelecionado.month - 1, 1);

    try {
      final snapshot = await db
          .collection('families')
          .doc(familyId)
          .collection('transactions')
          .get();

      final Map<String, List>> porCategoria = {};
      final Map<String, String> tipoCategoria = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['createdAt'] != null) {
          final Timestamp timestamp = data['createdAt'];
          final DateTime dataTx = timestamp.toDate();
          if (dataTx.year == mesAnterior.year && dataTx.month == mesAnterior.month) {
            final categoria = (data['categoria'] ?? 'Geral').toString();
            final tipo = (data['tipo'] ?? 'despesa').toString();
            porCategoria.putIfAbsent(categoria, () => []);
            porCategoria[categoria]!.add(data);
            tipoCategoria[categoria] = tipo;
          }
        }
      }

      if (porCategoria.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Nenhuma transação encontrada no mês anterior (${_formatarMes(mesAnterior)})!',
              ),
            ),
          );
        }
        return;
      }

      final categoriasOrdenadas = porCategoria.keys.toList()
        ..sort((a, b) {
          final tipoA = tipoCategoria[a] ?? 'despesa';
          final tipoB = tipoCategoria[b] ?? 'despesa';
          if (tipoA == 'receita' && tipoB != 'receita') return -1;
          if (tipoA != 'receita' && tipoB == 'receita') return 1;
          return a.compareTo(b);
        });

      final Set<String> selecionadas = Set<String>.from(categoriasOrdenadas);

      if (!context.mounted) return;

      await showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFFFAF6EE),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (ctx, setModalState) {
              final todasMarcadas = selecionadas.length == categoriasOrdenadas.length;

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selecionar planilhas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              if (todasMarcadas) {
                                selecionadas.clear();
                              } else {
                                selecionadas.addAll(categoriasOrdenadas);
                              }
                            });
                          },
                          child: Text(
                            todasMarcadas ? 'Desmarcar todas' : 'Marcar todas',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Origem: ${_formatarMes(mesAnterior)}  →  Destino: ${_formatarMes(mesDestino)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: categoriasOrdenadas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final cat = categoriasOrdenadas[index];
                          final isReceita = (tipoCategoria[cat] ?? 'despesa') == 'receita';
                          final marcada = selecionadas.contains(cat);

                          final Color corFaixa = isReceita
                              ? const Color(0xFFA8E6CF)
                              : const Color(0xFFFF8B94);
                          final Color corTexto = isReceita
                              ? const Color(0xFF1B4D3E)
                              : const Color(0xFF5C1D24);

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setModalState(() {
                                if (marcada) {
                                  selecionadas.remove(cat);
                                } else {
                                  selecionadas.add(cat);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: corFaixa,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white, width: 1.0),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: marcada,
                                    activeColor: corTexto,
                                    checkColor: Colors.white,
                                    side: BorderSide(color: corTexto, width: 1.8),
                                    onChanged: (val) {
                                      setModalState(() {
                                        if (val == true) {
                                          selecionadas.add(cat);
                                        } else {
                                          selecionadas.remove(cat);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      cat.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: corTexto,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: selecionadas.isEmpty
                          ? null
                          : () async {
                              final escolhidas = Set<String>.from(selecionadas);
                              Navigator.pop(sheetContext);
                              await _executarCopiaCategorias(
                                context: context,
                                familyId: familyId,
                                mesDestino: mesDestino,
                                transacoesPorCategoria: porCategoria,
                                categoriasSelecionadas: escolhidas,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCBDD),
                        foregroundColor: const Color(0xFF333333),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Copiar (${selecionadas.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar planilhas do mês anterior: $e')),
        );
      }
    }
  }
}
