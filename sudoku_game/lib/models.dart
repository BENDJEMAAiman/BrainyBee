import 'package:flutter/material.dart';

enum Difficulty { easy, medium, hard }

class SudokuConfig {
  final int size, boxRows, boxCols, clues;
  final String name;
  final Color color;
  const SudokuConfig({required this.size, required this.boxRows, required this.boxCols,
    required this.clues, required this.name, required this.color});
}

class SudokuCell {
  int value;
  final int solution;
  final bool fixed;
  bool error;
  SudokuCell({required this.value, required this.solution, required this.fixed, this.error = false});
}
