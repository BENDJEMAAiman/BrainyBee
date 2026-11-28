
import 'package:mobile_app_project/BrainyBee/game/model/game_card_model.dart';

enum FlipMatchStatus {
  initial,
  playing,
  paused,
  won,
}

class FlipMatchState {
  final List<GameCard> cards;
  final int moves;
  final int matchedPairs;
  final int elapsedSeconds;
  final FlipMatchStatus status;
  final bool isCheckingMatch;

  const FlipMatchState({
    this.cards = const [],
    this.moves = 0,
    this.matchedPairs = 0,
    this.elapsedSeconds = 0,
    this.status = FlipMatchStatus.initial,
    this.isCheckingMatch = false,
  });

  FlipMatchState copyWith({
    List<GameCard>? cards,
    int? moves,
    int? matchedPairs,
    int? elapsedSeconds,
    FlipMatchStatus? status,
    bool? isCheckingMatch,
  }) {
    return FlipMatchState(
      cards: cards ?? this.cards,
      moves: moves ?? this.moves,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      status: status ?? this.status,
      isCheckingMatch: isCheckingMatch ?? this.isCheckingMatch,
    );
  }
}
