import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HeroCard extends StatelessWidget {
  final bool mostrarSaldo;
  final VoidCallback onToggleVisibility;

  const HeroCard({
    super.key,
    required this.mostrarSaldo,
    required this.onToggleVisibility,
  });

  String _primeiroNome(String? nomeCompleto) {
    if (nomeCompleto == null || nomeCompleto.isEmpty) return 'Usuário';
    return nomeCompleto.trim().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final familyId = user?.uid ?? 'familia_default';
    final nomeExibicao = _primeiroNome(user?.displayName ?? user?.email?.split('@')[0]);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('transactions')
          .snapshots(),
      builder: (context, snapshot) {
        double totalReceitas = 0.0;
        double totalGastos = 0.0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['valor'] ?? 0.0).toDouble();
            final tipo = data['tipo'] ?? 'despesa';
            
            if (tipo == 'receita') {
              totalReceitas += amount;
            } else {
              totalGastos += amount;
            }
          }
        }

        final saldoTotal = totalReceitas - totalGastos;

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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Olá, $nomeExibicao! Este mês:',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const Text(
                    'Visão Geral',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Saldos Totais:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    mostrarSaldo
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
                    onTap: onToggleVisibility,
                    child: Icon(
                      mostrarSaldo ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 22,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildItemCard(
                'Receitas',
                mostrarSaldo ? 'R\$ ${totalReceitas.toStringAsFixed(2).replaceFirst('.', ',')}' : 'R\$ ••••••',
                const Color(0xFFA8E6CF),
                Icons.arrow_upward_rounded,
              ),
              const SizedBox(height: 12),
              _buildItemCard(
                'Gastos',
                mostrarSaldo ? 'R\$ ${totalGastos.toStringAsFixed(2).replaceFirst('.', ',')}' : 'R\$ ••••••',
                const Color(0xFFFF8B94),
                Icons.arrow_downward_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(String titulo, String valor, Color corIcone, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: corIcone, shape: BoxShape.circle),
            child: Icon(icone, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF222222))),
            ],
          ),
        ],
      ),
    );
  }
}
