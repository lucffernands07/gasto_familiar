import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/membro.dart';
import '../widgets/membro_tile.dart';

class VisaoGeralView extends StatelessWidget {
  final String familyId;
  final bool mostrarSaldo;
  final Function(BuildContext, String, Map<String, dynamic>) onEditMember;
  final Function(BuildContext, String) onDeleteMember;
  final VoidCallback onCreateMember;

  const VisaoGeralView({
    super.key,
    required this.familyId,
    required this.mostrarSaldo,
    required this.onEditMember,
    required this.onDeleteMember,
    required this.onCreateMember,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Saldos por Membro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
            ElevatedButton.icon(
              onPressed: onCreateMember,
              icon: const Icon(Icons.person_add, size: 14, color: Color(0xFF4A4A4A)),
              label: const Text('Adicionar Membro', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A))),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFEBE4),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFDCD6CD))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: db.collection('families').doc(familyId).collection('members').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF4A4A4A))),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text('Nenhum membro registrado. Clique em "Adicionar Membro" para começar!', style: TextStyle(color: Color(0xFF666666))),
              );
            }

            final docs = snapshot.data!.docs;
            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final membroId = doc.id;
                final membro = Membro(
                  nome: data['nome'] ?? 'Membro',
                  saldo: (data['saldo'] ?? 0.0).toDouble(),
                  imageUrl: data['imageUrl'] ?? 'https://i.pravatar.cc/150?img=12',
                  borderColor: const Color(0xFFA8DADC),
                );

                return MembroTile(
                  memberId: membroId,
                  membro: membro,
                  mostrarSaldo: mostrarSaldo,
                  onEdit: () => onEditMember(context, membroId, data),
                  onDelete: () => onDeleteMember(context, membroId),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
