import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_project/BrainyBee/game/business_logic/flip_match_state.dart';
import 'package:mobile_app_project/BrainyBee/game/data/flip_match_repository.dart';
import 'package:mobile_app_project/BrainyBee/game/model/game_config.dart';

class FlipMatchCubit extends Cubit<FlipMatchState> {
  final FlipMatchRepository _repository;

  FlipMatchCubit(this._repository) : super(const FlipMatchState());

  Timer? _timer;
  GameConfig? _config;

  int _sessionId = 0;
  bool _timerStarted = false;

  // Initialize a new game.
  void startGame(GameConfig config) {
    _sessionId++;

    _timer?.cancel();
    _timerStarted = false;
    _config = config;

    final cards = _repository.generateCards(config);

    emit(FlipMatchState(cards: cards, status: FlipMatchStatus.playing));
  }

  // Flip a card.
  Future<void> flipCard(int index) async {
    if (state.status != FlipMatchStatus.playing ||
        state.isCheckingMatch ||
        index < 0 ||
        index >= state.cards.length) {
      return;
    }

    final card = state.cards[index];

    if (card.isFlipped || card.isMatched) {
      return;
    }

    // Start the timer when the first card is flipped.
    if (!_timerStarted) {
      _startTimer();
    }

    final updatedCards = List.of(state.cards);

    updatedCards[index] = card.copyWith(isFlipped: true);

    final flippedIndices = updatedCards
        .asMap()
        .entries
        .where((entry) => entry.value.isFlipped && !entry.value.isMatched)
        .map((entry) => entry.key)
        .toList();

    // First card flipped.
    if (flippedIndices.length == 1) {
      emit(state.copyWith(cards: updatedCards));
      return;
    }

    // Second card flipped.
    final firstIndex = flippedIndices[0];
    final secondIndex = flippedIndices[1];

    final firstCard = updatedCards[firstIndex];
    final secondCard = updatedCards[secondIndex];

    final currentSession = _sessionId;

    emit(
      state.copyWith(
        cards: updatedCards,
        moves: state.moves + 1,
        isCheckingMatch: true,
      ),
    );

    // Check whether the cards match.
    if (firstCard.symbol == secondCard.symbol) {
      updatedCards[firstIndex] = firstCard.copyWith(isMatched: true);
      updatedCards[secondIndex] = secondCard.copyWith(isMatched: true);

      final newMatchedPairs = state.matchedPairs + 1;

      final hasWon = newMatchedPairs == _config!.pairs;

      if (hasWon) {
        _timer?.cancel();
      }

      emit(
        state.copyWith(
          cards: updatedCards,
          matchedPairs: newMatchedPairs,
          isCheckingMatch: false,
          status: hasWon ? FlipMatchStatus.won : FlipMatchStatus.playing,
        ),
      );
    } else {
      // Give the player time to see the incorrect pair.
      await Future.delayed(const Duration(milliseconds: 800));

      // Ignore outdated operations after restarting or closing the game.
      if (isClosed || currentSession != _sessionId) return;

      final currentCards = List.of(state.cards);

      currentCards[firstIndex] = currentCards[firstIndex].copyWith(
        isFlipped: false,
      );

      currentCards[secondIndex] = currentCards[secondIndex].copyWith(
        isFlipped: false,
      );

      emit(state.copyWith(cards: currentCards, isCheckingMatch: false));
    }
  }

  // Start the game timer.

  void _startTimer() {
    _timer?.cancel();
    _timerStarted = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == FlipMatchStatus.playing) {
        emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
      }
    });
  }

  // Pause the game.
  void pauseGame() {
    if (state.status != FlipMatchStatus.playing) return;

    _timer?.cancel();

    emit(state.copyWith(status: FlipMatchStatus.paused));
  }

  // Resume the game.
  void resumeGame() {
    if (state.status != FlipMatchStatus.paused) return;

    emit(state.copyWith(status: FlipMatchStatus.playing));

    if (_timerStarted) {
      _startTimer();
    }
  }

  // Restart the current game.
  void restartGame() {
    if (_config == null) return;

    startGame(_config!);
  }

  @override
  Future<void> close() {
    _sessionId++;
    _timer?.cancel();
    return super.close();
  }
}
