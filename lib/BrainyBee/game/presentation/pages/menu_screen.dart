
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/BrainyBee/game/model/game_config.dart';
import 'package:mobile_app_project/BrainyBee/game/presentation/widgets/difficulty_card.dart';
import 'package:mobile_app_project/BrainyBee/game/presentation/widgets/game_header.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class MenuScreen extends StatelessWidget {
  final ValueChanged<GameConfig> onDifficultySelected;

  const MenuScreen({
    super.key,
    required this.onDifficultySelected,
  });

  static const Map<Difficulty, GameConfig> _gameConfigs = {
    Difficulty.easy: GameConfig(
      gridSize: 3,
      pairs: 4,
      name: 'Easy',
    ),
    Difficulty.medium: GameConfig(
      gridSize: 4,
      pairs: 8,
      name: 'Medium',
    ),
    Difficulty.hard: GameConfig(
      gridSize: 5,
      pairs: 12,
      name: 'Hard',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GameHeader(),

              SizedBox(height: 30.h),

              Text(
                'Choose your difficulty',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingLarge,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                'Find all matching pairs and test your memory!',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.headingMedium,
                ),
              ),

              SizedBox(height: 22.h),

              ...Difficulty.values.map((difficulty) {
                final config = _gameConfigs[difficulty]!;

                return Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: DifficultyCard(
                    difficulty: difficulty,
                    config: config,
                    onTap: () => onDifficultySelected(config),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
