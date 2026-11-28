
import 'dart:math';

import 'package:mobile_app_project/BrainyBee/game/model/game_card_model.dart';
import 'package:mobile_app_project/BrainyBee/game/model/game_config.dart';


class FlipMatchRepository {
  final Random _random = Random();

  // Symbols available for the memory game.
  static const List<String> _symbols = [
    '🐶',
    '🐱',
    '🐼',
    '🦊',
    '🐸',
    '🐵',
    '🦁',
    '🐰',
    '🐨',
    '🐯',
    '🐷',
    '🐮',
  ];

  List<GameCard> generateCards(GameConfig config) {
    final selectedSymbols = _symbols.take(config.pairs).toList();

    final cardSymbols = [
      ...selectedSymbols,
      ...selectedSymbols,
    ];

    cardSymbols.shuffle(_random);

    return List.generate(
      cardSymbols.length,
      (index) => GameCard(
        id: index,
        symbol: cardSymbols[index],
      ),
    );
  }
}
