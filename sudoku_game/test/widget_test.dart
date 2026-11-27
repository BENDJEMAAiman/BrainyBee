
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_game/main.dart';

void main() {
  testWidgets('Sudoku menu displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const SudokuApp());

    expect(find.text('BrainyBee Games'), findsOneWidget);
    expect(find.text('Sudoku Challenge 🧩'), findsOneWidget);

    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
  });
}
