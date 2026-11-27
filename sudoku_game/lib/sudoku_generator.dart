import 'dart:math';

class SudokuPuzzle {
  final List<List<int>> puzzle, solution;
  SudokuPuzzle(this.puzzle, this.solution);
}

class SudokuGenerator {
  static SudokuPuzzle generate({required int size, required int boxRows,
    required int boxCols, required int clues}) {
    final random = Random();
    final base = List.generate(size, (r) => List.generate(size,
      (c) => (r * boxCols + r ~/ boxRows + c) % size + 1));

    final numbers = List<int>.generate(size, (i) => i + 1)..shuffle(random);
    final rowGroups = <List<int>>[];
    for (int i = 0; i < size; i += boxRows) {
      rowGroups.add(List<int>.generate(boxRows, (j) => i + j)..shuffle(random));
    }
    rowGroups.shuffle(random);
    final rows = rowGroups.expand((g) => g).toList();

    final colGroups = <List<int>>[];
    for (int i = 0; i < size; i += boxCols) {
      colGroups.add(List<int>.generate(boxCols, (j) => i + j)..shuffle(random));
    }
    colGroups.shuffle(random);
    final cols = colGroups.expand((g) => g).toList();

    final solution = List.generate(size, (r) => List.generate(size,
      (c) => numbers[base[rows[r]][cols[c]] - 1]));
    final puzzle = solution.map((r) => List<int>.from(r)).toList();
    final positions = List<int>.generate(size * size, (i) => i)..shuffle(random);
    for (int i = 0; i < size * size - clues; i++) {
      puzzle[positions[i] ~/ size][positions[i] % size] = 0;
    }
    return SudokuPuzzle(puzzle, solution);
  }
}
