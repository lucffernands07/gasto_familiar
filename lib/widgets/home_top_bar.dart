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
          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
              ? (photoUrl.startsWith('data:image')
                  ? MemoryImage(base64Decode(photoUrl.split(',')[1])) as ImageProvider
                  : NetworkImage(photoUrl))
              : null,
          child: photoUrl == null || photoUrl.isEmpty
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
