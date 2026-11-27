
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory_card_game/models.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final GameConfig config;

  const GameScreen({
    super.key,
    required this.difficulty,
    required this.config,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {

  // Game variables
  List<GameCard> cards = [];
  List<int> flippedCards = [];

  int moves = 0;
  int matches = 0;

  bool canFlip = true;
  bool gameStarted = false;
  bool isPaused = false;

  DateTime? gameStartTime;
  DateTime? pauseStartTime;

  Duration pausedDuration = Duration.zero;

  Timer? _uiTimer;

  late AnimationController _flipController;
  late AnimationController _matchController;
  late AnimationController _wrongController;

  final List<String> symbols = [
    '🍎', '🍌', '🍇', '🍉', '🍓', '🍒',
    '🥝', '🥑', '🥕', '🌽', '🥔', '🥦',
    '🥬', '🧄', '🧅', '🍆', '🌶️', '🫑'
  ];

  // Colors
  final Color backgroundColor = const Color(0xFFF3F6FF);
  final Color greenColor = const Color(0xFF22C46B);
  final Color orangeColor = const Color(0xFFFFA000);
  final Color darkColor = const Color(0xFF17243B);

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _matchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _wrongController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _initGame();

    // Refresh timer every second
    _uiTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (mounted && gameStarted && !isPaused) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _uiTimer?.cancel();

    _flipController.dispose();
    _matchController.dispose();
    _wrongController.dispose();

    super.dispose();
  }

  // Initialize or restart the game
  void _initGame() {
    cards.clear();
    flippedCards.clear();

    moves = 0;
    matches = 0;

    canFlip = true;
    gameStarted = false;
    isPaused = false;

    gameStartTime = null;
    pauseStartTime = null;
    pausedDuration = Duration.zero;

    List<String> gameSymbols =
        symbols.take(widget.config.pairs).toList();

    List<String> cardPairs = [
      ...gameSymbols,
      ...gameSymbols,
    ];

    int totalCards =
        widget.config.gridSize * widget.config.gridSize;

    while (cardPairs.length < totalCards) {
      cardPairs.add('⭐');
    }

    cardPairs.shuffle(Random());

    for (int i = 0; i < totalCards; i++) {
      cards.add(
        GameCard(
          id: i,
          symbol: cardPairs[i],
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  // Flip a card
  void _flipCard(int index) {
    if (isPaused ||
        !canFlip ||
        cards[index].isFlipped ||
        cards[index].isMatched ||
        cards[index].isAnimating ||
        flippedCards.length >= 2) {
      return;
    }

    if (!gameStarted) {
      gameStarted = true;
      gameStartTime = DateTime.now();
    }

    setState(() {
      cards[index].isFlipped = true;
      cards[index].isAnimating = true;
      flippedCards.add(index);
    });

    _flipController.forward().then((_) {
      if (!mounted) return;

      _flipController.reset();

      setState(() {
        cards[index].isAnimating = false;
      });
    });

    if (flippedCards.length == 2) {
      moves++;
      _checkForMatch();
    }
  }

  // Check if two cards match
  void _checkForMatch() {
    canFlip = false;

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      int firstIndex = flippedCards[0];
      int secondIndex = flippedCards[1];

      if (cards[firstIndex].symbol ==
          cards[secondIndex].symbol) {

        setState(() {
          cards[firstIndex].isMatched = true;
          cards[secondIndex].isMatched = true;

          matches++;
          flippedCards.clear();
          canFlip = true;
        });

        _matchController.forward().then((_) {
          if (mounted) {
            _matchController.reset();
          }
        });

        if (matches == widget.config.pairs) {
          _showWinDialog();
        }

      } else {

        _wrongController.forward().then((_) {
          if (!mounted) return;

          _wrongController.reset();

          setState(() {
            cards[firstIndex].isFlipped = false;
            cards[secondIndex].isFlipped = false;

            flippedCards.clear();
            canFlip = true;
          });
        });
      }
    });
  }

  // Calculate game time
  String _getGameTime() {
    if (gameStartTime == null) return '00:00';

    DateTime endTime =
        pauseStartTime ?? DateTime.now();

    Duration duration =
        endTime.difference(gameStartTime!) - pausedDuration;

    final minutes =
        duration.inMinutes.toString().padLeft(2, '0');

    final seconds =
        (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // Pause the game
  void _pauseGame() {
    if (!gameStarted || isPaused) return;

    setState(() {
      isPaused = true;
      pauseStartTime = DateTime.now();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            'Game Paused',
            textAlign: TextAlign.center,
          ),

          content: const Text(
            'Take a little break! Your progress is saved.',
            textAlign: TextAlign.center,
          ),

          actionsAlignment: MainAxisAlignment.center,

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  pausedDuration += DateTime.now()
                      .difference(pauseStartTime!);

                  pauseStartTime = null;
                  isPaused = false;
                });
              },

              child: const Text('Resume Game'),
            ),
          ],
        );
      },
    );
  }

  // Winning dialog
  void _showWinDialog() {
    final gameTime = _getGameTime();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Column(
            children: [
              Text(
                '🎉',
                style: TextStyle(fontSize: 50),
              ),

              SizedBox(height: 10),

              Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17243B),
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow(
                'Difficulty',
                widget.config.name,
                widget.config.color,
              ),

              _buildStatRow(
                'Timer',
                gameTime,
                Colors.blue,
              ),

              _buildStatRow(
                'Moves',
                moves.toString(),
                orangeColor,
              ),

              _buildStatRow(
                'Matches',
                '$matches/${widget.config.pairs}',
                greenColor,
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Menu'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initGame();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: Colors.white,
              ),

              child: const Text('Play again'),
            ),
          ],
        );
      },
    );
  }

  // Statistics row in winning dialog
  Widget _buildStatRow(
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(label),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // MAIN SCREEN
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [

            // HEADER
            _buildHeader(),

            const SizedBox(height: 10),

            // STATISTICS
            _buildStatistics(),

            const SizedBox(height: 10),

            // RESPONSIVE GAME GRID
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),

                child: LayoutBuilder(
                  builder: (context, constraints) {

                    final int gridSize =
                        widget.config.gridSize;

                    final double spacing = 7;

                    final double cardWidth =
                        (constraints.maxWidth -
                            (spacing * (gridSize - 1))) /
                        gridSize;

                    final double cardHeight =
                        (constraints.maxHeight -
                            (spacing * (gridSize - 1))) /
                        gridSize;

                    final double aspectRatio =
                        cardWidth / cardHeight;

                    return GridView.builder(
                      // No scrolling: every card fits on screen
                      physics:
                          const NeverScrollableScrollPhysics(),

                      padding: EdgeInsets.zero,

                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: aspectRatio,
                      ),

                      itemCount: cards.length,

                      itemBuilder: (context, index) {
                        return _buildCard(index);
                      },
                    );
                  },
                ),
              ),
            ),

            // BOTTOM REWARD AND PAUSE
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),

      color: Colors.white,

      child: Row(
        children: [

          _buildHeaderButton(
            Icons.arrow_back,
            () => Navigator.pop(context),
          ),

          const Spacer(),

          Column(
            children: [
              Text(
                '${widget.config.name} Mode',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),

              const SizedBox(height: 3),

              const Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: Color(0xFF22C46B),
                    size: 8,
                  ),

                  SizedBox(width: 5),

                  Text(
                    'MEMORY MASTER',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFFB77B24),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          _buildHeaderButton(
            Icons.refresh,
            () {
              _initGame();
            },
          ),
        ],
      ),
    );
  }

  // HEADER BUTTON
  Widget _buildHeaderButton(
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),

      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: darkColor,
          size: 24,
        ),
      ),
    );
  }

  // STATISTICS SECTION
  Widget _buildStatistics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),

      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          _buildStatCard(
            Icons.timer,
            _getGameTime(),
            'TIME',
            const Color(0xFF0E9ED5),
            const Color(0xFFE4F5FC),
          ),

          _buildStatCard(
            Icons.touch_app,
            moves.toString(),
            'MOVES',
            const Color(0xFFF28A27),
            const Color(0xFFFFF0E2),
          ),

          _buildStatCard(
            Icons.check_circle,
            '$matches/${widget.config.pairs}',
            'PAIRS',
            greenColor,
            const Color(0xFFE4F8EB),
          ),
        ],
      ),
    );
  }

  // INDIVIDUAL STATISTICS CIRCLE
  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
    Color background,
  ) {
    return Container(
      width: 85,
      height: 85,

      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,

        border: Border.all(
          color: color.withOpacity(0.12),
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: TextStyle(
              color: darkColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            label,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // BOTTOM REWARD AND PAUSE SECTION
  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),

      color: backgroundColor,

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),

            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),

                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2D6),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFE9A526),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Reward on Clear',
                        style: TextStyle(
                          color: darkColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      const Text(
                        'Complete all pairs!',
                        style: TextStyle(
                          color: Color(0xFFB77B24),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.star,
                  color: Color(0xFFFFB52E),
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          TextButton.icon(
            onPressed: _pauseGame,

            icon: const Icon(
              Icons.pause_circle_filled,
              size: 15,
            ),

            label: const Text(
              'Pause Game',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            style: TextButton.styleFrom(
              foregroundColor: Colors.blueGrey,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // INDIVIDUAL MEMORY CARD
  Widget _buildCard(int index) {
    GameCard card = cards[index];

    bool showFront = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: () => _flipCard(index),

      child: LayoutBuilder(
        builder: (context, constraints) {

          // Adapt emoji size to the card dimensions
          final double cardFontSize =
              min(
                constraints.maxWidth,
                constraints.maxHeight,
              ) * 0.43;

          return AnimatedBuilder(
            animation: Listenable.merge([
              _matchController,
              _wrongController,
            ]),

            builder: (context, child) {
              double scale = 1.0;
              double shake = 0.0;

              if (card.isMatched) {
                scale =
                    1.0 + (_matchController.value * 0.08);
              }

              if (flippedCards.contains(index) &&
                  !card.isMatched) {
                shake = _wrongController.value * 5;
              }

              return Transform.translate(
                offset: Offset(shake, 0),

                child: Transform.scale(
                  scale: scale,

                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 250,
                    ),

                    decoration: BoxDecoration(
                      color: card.isMatched
                          ? const Color(0xFF22C46B)
                          : showFront
                              ? const Color(0xFFFFF6E8)
                              : greenColor,

                      borderRadius: BorderRadius.circular(14),

                      border: Border.all(
                        color: showFront
                            ? orangeColor
                            : const Color(0xFF18AD5B),
                        width: showFront ? 2 : 1,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.13),
                          blurRadius: 3,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Center(
                      child: showFront
                          ? Text(
                              card.symbol,
                              style: TextStyle(
                                fontSize: cardFontSize,
                              ),
                            )
                          : Icon(
                              Icons.question_mark,
                              color: Colors.white,
                              size: cardFontSize,
                              weight: 700,
                            ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
