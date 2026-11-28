
class GameCard {
  final int id;
  final String symbol;
  final bool isFlipped;
  final bool isMatched;

  const GameCard({
    required this.id,
    required this.symbol,
    this.isFlipped = false,
    this.isMatched = false,
  });

  GameCard copyWith({
    bool? isFlipped,
    bool? isMatched,
  }) {
    return GameCard(
      id: id,
      symbol: symbol,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
