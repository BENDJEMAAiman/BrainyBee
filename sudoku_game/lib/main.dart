
import 'package:flutter/material.dart';
import 'menu_screen.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudoku Master',
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF3F6FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22C46B),
        ),
      ),
      home: const MenuScreen(),
    );
  }
}
