
enum Difficulty {
  easy,
  medium,
  hard,
}

class GameConfig {
  final int gridSize;
  final int pairs;
  final String name;

  const GameConfig({
    required this.gridSize,
    required this.pairs,
    required this.name,
  });
}