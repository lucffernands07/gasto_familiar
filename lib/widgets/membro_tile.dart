import 'package:flutter/material.dart';
import '../models/membro.dart';

class MembroTile extends StatelessWidget {
  final Membro membro;
  final bool mostrarSaldo;

  const MembroTile({
    super.key,
    required this.membro,
    required this.mostrarSaldo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: membro.borderColor, width: 3),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(membro.imageUrl),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${membro.nome}:',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mostrarSaldo
                    ? 'R\$ ${membro.saldo.toStringAsFixed(2).replaceAll('.', ',')}'
                    : 'R\$ ••••••',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
