import 'dart:async';
import 'package:flutter/material.dart';
import 'models.dart';
import 'sudoku_generator.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final SudokuConfig config;
  const GameScreen({super.key, required this.difficulty, required this.config});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<SudokuCell>> board;
  int? selectedRow, selectedCol;
  int mistakes = 0, hints = 3, seconds = 0;
  bool paused = false, finished = false;
  Timer? timer;

  final bg = const Color(0xFFF3F6FF);
  final green = const Color(0xFF22C46B);
  final orange = const Color(0xFFFFA000);
  final dark = const Color(0xFF17243B);

  @override
  void initState() {
    super.initState();
    _newGame();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !paused && !finished) setState(() => seconds++);
    });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  void _newGame() {
    final generated = SudokuGenerator.generate(size: widget.config.size,
      boxRows: widget.config.boxRows, boxCols: widget.config.boxCols,
      clues: widget.config.clues);
    board = List.generate(widget.config.size, (r) => List.generate(widget.config.size, (c) {
      final v = generated.puzzle[r][c];
      return SudokuCell(value: v, solution: generated.solution[r][c], fixed: v != 0);
    }));
    selectedRow = selectedCol = null;
    mistakes = 0; hints = 3; seconds = 0; paused = false; finished = false;
    if (mounted) setState(() {});
  }

  String get timeText => '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  void _select(int r, int c) {
    if (paused || finished || board[r][c].fixed) return;
    setState(() { selectedRow = r; selectedCol = c; });
  }

  void _enter(int number) {
    if (selectedRow == null || paused || finished) return;
    final cell = board[selectedRow!][selectedCol!];
    if (cell.fixed) return;
    setState(() {
      cell.value = number;
      cell.error = number != cell.solution;
      if (cell.error) mistakes++;
    });
    if (_completed()) _win();
  }

  void _erase() {
    if (selectedRow == null || paused || finished) return;
    final cell = board[selectedRow!][selectedCol!];
    if (!cell.fixed) setState(() { cell.value = 0; cell.error = false; });
  }

  bool _completed() => board.every((row) => row.every((cell) => cell.value == cell.solution));

  void _hint() {
    if (hints <= 0 || selectedRow == null || paused || finished) return;
    final cell = board[selectedRow!][selectedCol!];
    if (cell.fixed) return;
    setState(() { cell.value = cell.solution; cell.error = false; hints--; });
    if (_completed()) _win();
  }

  void _pause() {
    if (paused || finished) return;
    setState(() => paused = true);
    showDialog(context: context, barrierDismissible: false, builder: (d) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text('Game Paused', textAlign: TextAlign.center),
      content: const Text('Take a little break! Your progress is saved.', textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [ElevatedButton(onPressed: () { Navigator.pop(d); setState(() => paused = false); },
        child: const Text('Resume Game'))],
    ));
  }

  void _win() {
    finished = true;
    showDialog(context: context, barrierDismissible: false, builder: (d) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Column(children: [Text('🎉', style: TextStyle(fontSize: 48)), SizedBox(height: 8),
        Text('Well Done!', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xFF17243B)))]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _result('Level', widget.config.name, widget.config.color),
        _result('Time', timeText, Colors.blue),
        _result('Mistakes', '$mistakes', orange),
      ]),
      actions: [
        TextButton(onPressed: () { Navigator.pop(d); Navigator.pop(context); }, child: const Text('Menu')),
        ElevatedButton(onPressed: () { Navigator.pop(d); _newGame(); },
          style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
          child: const Text('Play again')),
      ],
    ));
  }

  Widget _result(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    ]),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bg,
    body: SafeArea(child: Column(children: [
      _header(),
      _stats(),
      Expanded(child: Center(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: LayoutBuilder(builder: (context, constraints) {
          // Keep the Sudoku board square and fit it in the available width/height.
          final side = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;
          return SizedBox(width: side, height: side, child: _board());
        }),
      ))),
      _numberPad(),
      _bottom(),
    ])),
  );

  Widget _header() => Container(color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    child: Row(children: [
      _headerButton(Icons.arrow_back, () => Navigator.pop(context)),
      const Spacer(),
      Column(children: [
        Text('${widget.config.name} Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: dark)),
        const SizedBox(height: 2),
        const Text('SUDOKU MASTER', style: TextStyle(fontSize: 9, color: Color(0xFFB77B24), fontWeight: FontWeight.bold, letterSpacing: 1)),
      ]),
      const Spacer(),
      _headerButton(Icons.refresh, _newGame),
    ]));

  Widget _headerButton(IconData icon, VoidCallback action) => Material(
    color: bg, shape: const CircleBorder(),
    child: IconButton(onPressed: action, icon: Icon(icon, color: dark, size: 21),
      constraints: const BoxConstraints.tightFor(width: 42, height: 42), padding: EdgeInsets.zero));

  Widget _stats() => Padding(padding: const EdgeInsets.fromLTRB(12, 7, 12, 3),
    child: Row(children: [
      _stat(Icons.timer, timeText, 'TIME', Colors.blue),
      const SizedBox(width: 7),
      _stat(Icons.error_outline, '$mistakes', 'MISTAKES', orange),
      const SizedBox(width: 7),
      _stat(Icons.lightbulb_outline, '$hints', 'HINTS', green),
    ]));

  Widget _stat(IconData icon, String value, String label, Color color) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 7),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      Icon(icon, color: color, size: 17),
      Text(value, style: TextStyle(color: dark, fontWeight: FontWeight.bold, fontSize: 14)),
      Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 8, fontWeight: FontWeight.bold)),
    ])));

  Widget _board() {
    final n = widget.config.size;
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: dark, width: 2),
        borderRadius: BorderRadius.circular(7), boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 9, offset: const Offset(0, 3)),
        ]),
      child: Column(children: List.generate(n, (r) => Expanded(child: Row(children: List.generate(n, (c) =>
        Expanded(child: _cell(r, c))))))),
    );
  }

  Widget _cell(int r, int c) {
    final cell = board[r][c];
    final selected = selectedRow == r && selectedCol == c;
    final sameRow = selectedRow == r, sameCol = selectedCol == c;
    final selectedValue = selectedRow == null ? 0 : board[selectedRow!][selectedCol!].value;
    final sameNumber = selectedValue != 0 && cell.value == selectedValue;
    Color color = Colors.white;
    if (sameRow || sameCol) color = const Color(0xFFF0F6FF);
    if (sameNumber) color = const Color(0xFFE4F8EB);
    if (selected) color = const Color(0xFFFFE8B8);
    if (cell.error) color = const Color(0xFFFFE1E1);
    final n = widget.config.size;
    final thickR = (c + 1) % widget.config.boxCols == 0 && c != n - 1;
    final thickB = (r + 1) % widget.config.boxRows == 0 && r != n - 1;
    return GestureDetector(onTap: () => _select(r, c), child: Container(
      decoration: BoxDecoration(color: color, border: Border(
        right: BorderSide(color: dark.withOpacity(thickR ? .8 : .18), width: thickR ? 2 : .5),
        bottom: BorderSide(color: dark.withOpacity(thickB ? .8 : .18), width: thickB ? 2 : .5),
      )),
      child: Center(child: FittedBox(child: Text(cell.value == 0 ? '' : '${cell.value}',
        style: TextStyle(fontSize: 30, fontWeight: cell.fixed ? FontWeight.w800 : FontWeight.w600,
          color: cell.error ? Colors.red : cell.fixed ? dark : const Color(0xFF168C55))))),
    ));
  }

  Widget _numberPad() {
    final n = widget.config.size;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: List.generate(n, (i) => Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2), child: SizedBox(height: 38,
            child: ElevatedButton(onPressed: () => _enter(i + 1),
              style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.white, foregroundColor: dark,
                padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9),
                  side: BorderSide(color: green.withOpacity(.25)))),
              child: Text('${i + 1}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
        ))))),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(child: _action(Icons.backspace_outlined, 'Erase', orange, _erase)),
          const SizedBox(width: 7),
          Expanded(child: _action(Icons.lightbulb_outline, 'Hint', green, _hint)),
        ]),
      ]));
  }

  Widget _action(IconData icon, String label, Color color, VoidCallback action) => SizedBox(height: 32,
    child: OutlinedButton.icon(onPressed: action, icon: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color.withOpacity(.35)),
        padding: const EdgeInsets.symmetric(horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)))));

  Widget _bottom() => Padding(padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
    child: Row(children: [
      const Expanded(child: Text('Fill every row, column & box!', style: TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.w600))),
      TextButton.icon(onPressed: _pause, icon: const Icon(Icons.pause_circle_filled, size: 16),
        label: const Text('Pause', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(foregroundColor: dark, padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(0, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
    ]));
}
