import 'package:flutter/material.dart';

class Membro {
  final String nome;
  final double saldo;
  final String imageUrl;
  final Color borderColor;

  const Membro({
    required this.nome,
    required this.saldo,
    required this.imageUrl,
    required this.borderColor,
  });
}
