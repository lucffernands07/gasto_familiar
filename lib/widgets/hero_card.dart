import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/family_service.dart';

class HeroCard extends StatefulWidget {
  final bool mostrarSaldo;
  final VoidCallback onToggleVisibility;
  final DateTime mesSelecionado;
  final VoidCallback? onTapSaldoFamilia;
  final VoidCallback? onTapReceitas;
  final VoidCallback? onTapGastos;

  const HeroCard({
    super.key,
    required this.mostrarSaldo,
    required this.onToggleVisibility,
    required this.mesSelecionado,
    this.onTapSaldoFamilia,
    this.onTapReceitas,
    this.onTapGastos,
  });

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard> {
  String _greetingName = 'Usuário';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregarNomeGreeting();
  }

  Future<void> _carregarNomeGreeting() async {
    final nome = await FamilyService().getGreetingName();
    if (mounted) {
      setState(() {
        _greetingName = nome;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final familyId = user?.uid ?? 'familia_default';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('members')
          .snapshots(),
      builder: (context, memberSnapshot) {
        double totalMembros = 0.0;
        if (memberSnapshot.hasData) {
          for (var doc in memberSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalMembros += (data['saldo'] ?? 0.0).toDouble();
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .collection('transactions')
              .snapshots(),
          builder: (context, txSnapshot) {
            double receitasEfetivas = 0.0;
            double gastosEfetivos = 0.0;
            double receitasPrevias = 0.0;
            double gastosPrevios = 0.0;

            if (txSnapshot.hasData) {
              for (var doc in txSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                
                // Filtrar por mês e ano selecionados
                if (data['createdAt'] != null) {
                  final Timestamp timestamp = data['createdAt'];
                  final DateTime dataTx = timestamp.toDate();
                  
                  if (dataTx.year != widget.mesSelecionado.year || 
                      dataTx.month != widget.mesSelecionado.month) {
                    continue; 
                  }
                }

                final amount = (data['valor'] ?? 0.0).toDouble();
                final tipo = data['tipo'] ?? 'despesa';
                final status = data['status'] ?? (tipo == 'receita' ? 'Recebido' : 'Pago');

                if (tipo == 'receita') {
                  receitasPrevias += amount;
                  if (status == 'Recebido') {
                    receitasEfetivas += amount;
                  }
                } else {
                  gastosPrevios += amount;
                  if (status == 'Pago') {
                    gastosEfetivos += amount;
                  }
                }
              }
            }

            final saldoTotal = receitasEfetivas - gastosEfetivos;
            final saldoPrevio = receitasPrevias - gastosPrevios;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFCBDD), Color(0xFFFFF3E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saudação limpa sem abas
                  Text(
                    'Olá, $_greetingName!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Subtítulo
                  const Text(
                    'Resumo deste mês',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Saldos Totais:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF555555),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.mostrarSaldo
                                  ? 'R\$ ${saldoTotal.toStringAsFixed(2).replaceFirst('.', ',')}'
                                  : 'R\$ ••••••',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: widget.onToggleVisibility,
                              child: Icon(
                                widget.mostrarSaldo ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 22,
                                color: const Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.mostrarSaldo
                              ? 'Saldo previsto: R\$ ${saldoPrevio.toStringAsFixed(2).replaceFirst('.', ',')}'
                              : 'Saldo previsto: R\$ ••••••',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Cartão Saldo Família (Clicável)
                  GestureDetector(
                    onTap: widget.onTapSaldoFamilia,
                    child: _buildItemCard(
                      'Saldo Família',
                      widget.mostrarSaldo ? 'R\$ ${totalMembros.toStringAsFixed(2).replaceFirst('.', ',')}' : 'R\$ ••••••',
                      const Color(0xFF80DEEA),
                      Icons.people_outline,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Cartão Receitas (Clicável)
                  GestureDetector(
                    onTap: widget.onTapReceitas,
                    child: _buildItemCard(
                      'Receitas (Recebidas)',
                      widget.mostrarSaldo ? 'R\$ ${receitasEfetivas.toStringAsFixed(2).replaceFirst('.', ',')}' : 'R\$ ••••••',
                      const Color(0xFFA8E6CF),
                      Icons.arrow_upward_rounded,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Cartão Gastos (Clicável)
                  GestureDetector(
                    onTap: widget.onTapGastos,
                    child: _buildItemCard(
                      'Gastos (Pagos)',
                      widget.mostrarSaldo ? 'R\$ ${gastosEfetivos.toStringAsFixed(2).replaceFirst('.', ',')}' : 'R\$ ••••••',
                      const Color(0xFFFF8B94),
                      Icons.arrow_downward_rounded,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemCard(String titulo, String valor, Color corIcone, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: corIcone, shape: BoxShape.circle),
            child: Icon(icone, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF222222))),
            ],
          ),
        ],
      ),
    );
  }
}
