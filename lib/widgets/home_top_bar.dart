import 'dart:convert';
import 'package:flutter/material.dart';

class HomeTopBar extends StatelessWidget {
  final String appTitle;
  final String? photoUrl;
  final String fallbackLetter;
  final Color titleColor;
  final Color iconColor;

  const HomeTopBar({
    super.key,
    required this.appTitle,
    required this.photoUrl,
    required this.fallbackLetter,
    required this.titleColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Atribuição a uma variável local para permitir a promoção de tipo (null-safety)
    final url = photoUrl;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, size: 32, color: iconColor),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        Text(
          appTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: titleColor,
            letterSpacing: -0.5,
          ),
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFFFCBDD),
          backgroundImage: url != null && url.isNotEmpty
              ? (url.startsWith('data:image')
                  ? MemoryImage(base64Decode(url.split(',')[1])) as ImageProvider
                  : NetworkImage(url))
              : null,
          child: url == null || url.isEmpty
              ? Text(
                  fallbackLetter,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                )
              : null,
        ),
      ],
    );
  }
}
