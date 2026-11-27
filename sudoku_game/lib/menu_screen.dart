import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'models.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const Color backgroundColor = Color(0xFFF3F6FF);
  static const Color darkColor = Color(0xFF17243B);
  static const Color orangeColor = Color(0xFFFFA91F);

  Widget _headerCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 19, color: darkColor),
      ),
    );
  }

  Widget _difficultyCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String size,
    required Color color,
    required Difficulty difficulty,
    required SudokuConfig config,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(
              difficulty: difficulty,
              config: config,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: color.withOpacity(0.13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 17,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigationBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 82,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE8EAF0)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, Icons.home_outlined, 'Home', false),
            _navItem(context, Icons.menu_book_outlined, 'Learning', false),
            _navItem(context, Icons.access_alarm, 'Routines', false),
            _navItem(context, Icons.sports_esports, 'Games', true),
            _navItem(context, Icons.face_outlined, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool selected,
  ) {
    return GestureDetector(
      onTap: () {
        if (!selected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label section is not available here yet.'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFF1D5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 25,
                color: selected
                    ? orangeColor
                    : const Color(0xFF9AA8BC),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? orangeColor
                    : const Color(0xFF8E9DB5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: _bottomNavigationBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _headerCircle(
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0CB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '🐝',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'BrainyBee Games',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                'Sudoku Challenge 🧩',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Choose your difficulty and start playing!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 28),

              _difficultyCard(
                context,
                title: 'Easy',
                subtitle: 'Perfect for beginners',
                size: '4×4',
                color: const Color(0xFF22C46B),
                difficulty: Difficulty.easy,
                config: SudokuConfig(
                  size: 4,
                  boxRows: 2,
                  boxCols: 2,
                  clues: 9,
                  name: 'Easy',
                  color: const Color(0xFF22C46B),
                ),
              ),

              const SizedBox(height: 16),

              _difficultyCard(
                context,
                title: 'Medium',
                subtitle: 'A little more challenging',
                size: '6×6',
                color: const Color(0xFFFFA000),
                difficulty: Difficulty.medium,
                config: SudokuConfig(
                  size: 6,
                  boxRows: 2,
                  boxCols: 3,
                  clues: 18,
                  name: 'Medium',
                  color: const Color(0xFFFFA000),
                ),
              ),

              const SizedBox(height: 16),

              _difficultyCard(
                context,
                title: 'Hard',
                subtitle: 'Ready for a big challenge?',
                size: '9×9',
                color: const Color(0xFFE85D5D),
                difficulty: Difficulty.hard,
                config: SudokuConfig(
                  size: 9,
                  boxRows: 3,
                  boxCols: 3,
                  clues: 35,
                  name: 'Hard',
                  color: const Color(0xFFE85D5D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}