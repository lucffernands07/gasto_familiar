import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GastoFamiliarApp());
}

class GastoFamiliarApp extends StatelessWidget {
  const GastoFamiliarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gasto Familiar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFAF6EE),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

