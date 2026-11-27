
import 'package:flutter/material.dart';
import 'package:memory_card_game/models.dart';
import 'package:memory_card_game/game_screen.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({super.key});

  // Difficulty configurations
  final Map<Difficulty, GameConfig> configs = {
    Difficulty.easy: GameConfig(
      gridSize: 3,
      pairs: 4,
      name: 'Easy',
      color: const Color(0xFF25C58A),
      icon: Icons.sentiment_satisfied,
    ),

    Difficulty.medium: GameConfig(
      gridSize: 4,
      pairs: 8,
      name: 'Medium',
      color: const Color(0xFFFFB52E),
      icon: Icons.sentiment_neutral,
    ),

    Difficulty.hard: GameConfig(
      gridSize: 5,
      pairs: 12,
      name: 'Hard',
      color: const Color(0xFFF05A78),
      icon: Icons.sentiment_very_satisfied,
    ),
  };

  final Color darkColor = const Color(0xFF17243B);
  final Color backgroundColor = const Color(0xFFF3F6FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [

            // TOP HEADER
            _buildHeader(),

            // MAIN CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),

                child: Column(
                  children: [

                    // GAME LOGO
                    _buildGameLogo(),

                    const SizedBox(height: 25),

                    // DIFFICULTY CARDS
                    ...Difficulty.values.map((difficulty) {
                      final config = configs[difficulty]!;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),

                        child: _buildDifficultyCard(
                          context,
                          difficulty,
                          config,
                        ),
                      );
                    }),

                    const SizedBox(height: 5),

                    // BEST SCORE
                    _buildBestScore(),

                    const SizedBox(height: 18),

                    const Text(
                      '👇  Pick a difficulty to jump in!',
                      style: TextStyle(
                        color: Color(0xFF8997AD),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM NAVIGATION
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // TOP HEADER
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),

      child: Row(
        children: [

          // Back icon
          _headerCircle(Icons.arrow_back),

          const SizedBox(width: 8),

          // BrainyBee logo
          Container(
            width: 28,
            height: 28,

            decoration: BoxDecoration(
              color: const Color(0xFFFFF0CB),
              borderRadius: BorderRadius.circular(8),
            ),

            child: const Center(
              child: Text('🐝', style: TextStyle(fontSize: 18)),
            ),
          ),

          const SizedBox(width: 6),

          // App name
          const Expanded(
            child: Text(
              'BrainyBee Games',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF17243B),
              ),
            ),
          ),

          // Honey drops
          _headerBadge('🍯 120'),

          const SizedBox(width: 5),

          // Streak
          _headerBadge('🔥 5d'),

          const SizedBox(width: 5),

          // Pro
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFFFFF1D6),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Text(
              'Pro',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB57A15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCircle(IconData icon) {
    return Container(
      width: 32,
      height: 32,

      decoration: const BoxDecoration(
        color: Color(0xFFF0F3F8),
        shape: BoxShape.circle,
      ),

      child: Icon(
        icon,
        size: 19,
        color: const Color(0xFF536276),
      ),
    );
  }

  Widget _headerBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF6E6C1),
        ),
      ),

      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF946B27),
        ),
      ),
    );
  }

  // GAME LOGO AND TITLE
  Widget _buildGameLogo() {
    return Column(
      children: [

        // Brain illustration
        Container(
          width: 90,
          height: 90,

          decoration: BoxDecoration(
            color: const Color(0xFFFFF0CB),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD878),
              width: 2,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: const Center(
            child: Text(
              '🧠',
              style: TextStyle(fontSize: 48),
            ),
          ),
        ),

        const SizedBox(height: 5),

        // Pro brain label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),

          decoration: BoxDecoration(
            color: const Color(0xFFFFA51F),
            borderRadius: BorderRadius.circular(12),
          ),

          child: const Text(
            'PRO BRAIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Memory Master',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: darkColor,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Flip & match cards to train your super brain and earn\nhoney drops!',
          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 11,
            height: 1.5,
            color: Color(0xFF75839A),
          ),
        ),
      ],
    );
  }

  // DIFFICULTY CARD
  Widget _buildDifficultyCard(
    BuildContext context,
    Difficulty difficulty,
    GameConfig config,
  ) {
    String description = '';
    String level = '';
    String reward = '';
    String emoji = '';

    switch (difficulty) {
      case Difficulty.easy:
        description = '3x3 Grid • 4 Pairs • Perfect for\nbeginners';
        level = 'LEVEL 1';
        reward = '+20 Honey Drops';
        emoji = '😊';
        break;

      case Difficulty.medium:
        description = '4x4 Grid • 8 Pairs • Balanced\nChallenge';
        level = 'LEVEL 2';
        reward = '+50 Honey Drops';
        emoji = '😄';
        break;

      case Difficulty.hard:
        description = '5x5 Grid • 12 Pairs • Expert Level';
        level = 'MASTER';
        reward = '+100 Honey Drops';
        emoji = '😎';
        break;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [

        // Main card
        Material(
          color: Colors.transparent,

          child: InkWell(
            borderRadius: BorderRadius.circular(16),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    difficulty: difficulty,
                    config: config,
                  ),
                ),
              );
            },

            child: Container(
              width: double.infinity,

              padding: const EdgeInsets.all(13),

              decoration: BoxDecoration(
                color: config.color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),

                border: Border.all(
                  color: config.color.withOpacity(0.8),
                  width: 1.2,
                ),

                boxShadow: [
                  BoxShadow(
                    color: config.color.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: Row(
                children: [

                  // Difficulty emoji
                  Container(
                    width: 49,
                    height: 49,

                    decoration: BoxDecoration(
                      color: config.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(13),
                    ),

                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Difficulty information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        // Name and level
                        Wrap(
                          spacing: 7,
                          crossAxisAlignment: WrapCrossAlignment.center,

                          children: [
                            Text(
                              config.name,

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkColor,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),

                              decoration: BoxDecoration(
                                color: config.color,
                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Text(
                                level,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // Description
                        Text(
                          description,

                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.4,
                            color: Color(0xFF46566B),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Reward
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Text(
                            '🍯 $reward',

                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF92651C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Arrow button
                  Container(
                    width: 30,
                    height: 30,

                    decoration: BoxDecoration(
                      color: config.color,
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Popular label for medium
        if (difficulty == Difficulty.medium)
          Positioned(
            right: 12,
            top: -5,

            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFE99B17),
                borderRadius: BorderRadius.circular(6),
              ),

              child: const Text(
                '★ POPULAR',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // BEST SCORE SECTION
  Widget _buildBestScore() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [

          // Trophy
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: const Color(0xFFFFF1C9),
              borderRadius: BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFFE9A526),
              size: 23,
            ),
          ),

          const SizedBox(width: 10),

          // Score information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'YOUR BEST SCORE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8997AD),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Play a game to set your record',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: darkColor,
                  ),
                ),
              ],
            ),
          ),

          // Score placeholder
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E8),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Row(
              children: [
                Text(
                  '— pts',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB78625),
                  ),
                ),

                SizedBox(width: 5),

                Icon(
                  Icons.star,
                  color: Color(0xFFE9A526),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BOTTOM NAVIGATION
  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          _buildNavItem(
            Icons.home_outlined,
            'Home',
            false,
          ),

          _buildNavItem(
            Icons.menu_book_outlined,
            'Learning',
            false,
          ),

          _buildNavItem(
            Icons.alarm,
            'Routines',
            false,
          ),

          _buildNavItem(
            Icons.sports_esports,
            'Games',
            true,
          ),

          _buildNavItem(
            Icons.face_outlined,
            'Profile',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool selected,
  ) {
    final color = selected
        ? const Color(0xFFE9A526)
        : const Color(0xFF98A5B7);

    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),

          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFF2D6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),

          child: Icon(
            icon,
            size: 21,
            color: color,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
