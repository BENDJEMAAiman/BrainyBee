
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/BrainyBee/game/business_logic/flip_match_cubit.dart';
import 'package:mobile_app_project/BrainyBee/game/business_logic/flip_match_state.dart';
import 'package:mobile_app_project/BrainyBee/game/model/game_config.dart';
import 'package:mobile_app_project/BrainyBee/game/presentation/widgets/game_buttom_section.dart';
import 'package:mobile_app_project/BrainyBee/game/presentation/widgets/game_statistics.dart';
import 'package:mobile_app_project/BrainyBee/game/presentation/widgets/memory_card.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class GameScreen extends StatelessWidget {
  final GameConfig config;
  final VoidCallback onExit;

  const GameScreen({
    super.key,
    required this.config,
    required this.onExit,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showPauseDialog(BuildContext context) {
    final cubit = context.read<FlipMatchCubit>();

    cubit.pauseGame();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Game Paused'),
          content: const Text('Take a break! Your progress is saved.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.resumeGame();
              },
              child: const Text('Resume'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.restartGame();
              },
              child: const Text('Restart'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onExit();
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  void _showVictoryDialog(BuildContext context, FlipMatchState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Amazing Work!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('You found all the matching pairs!'),
              SizedBox(height: 16.h),
              Text('Moves: ${state.moves}'),
              Text('Time: ${_formatTime(state.elapsedSeconds)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<FlipMatchCubit>().restartGame();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onExit();
              },
              child: const Text('Back to Menu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FlipMatchCubit, FlipMatchState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == FlipMatchStatus.won,
      listener: (context, state) {
        _showVictoryDialog(context, state);
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.authBackground,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 12.h,
              ),
              child: Column(
                children: [
                  // Game title and exit button.
                  Row(
                    children: [
                      IconButton(
                        onPressed: onExit,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Text(
                          'Flip Match',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.headingLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showPauseDialog(context),
                        icon: const Icon(Icons.pause_circle_outline_rounded),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Game statistics.
                  GameStatistics(
                    moves: state.moves,
                    elapsedSeconds: state.elapsedSeconds,
                    matchedPairs: state.matchedPairs,
                    totalPairs: config.pairs,
                  ),

                  SizedBox(height: 20.h),

                  // Memory card grid.
                  Expanded(
                    child: GridView.builder(
                      itemCount: state.cards.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: config.gridSize,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final card = state.cards[index];

                        return MemoryCard(
                          card: card,
                          onTap: () {
                            context
                                .read<FlipMatchCubit>()
                                .flipCard(index);
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Bottom controls.
                  GameBottomSection(
                    onPause: () => _showPauseDialog(context),
                    points: 0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
