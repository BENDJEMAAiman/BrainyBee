
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/BrainyBee/game/model/game_config.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final GameConfig config;
  final VoidCallback onTap;

  const DifficultyCard({
    super.key,
    required this.difficulty,
    required this.config,
    required this.onTap,
  });

  Color get difficultyColor {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  IconData get difficultyIcon {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied_alt_rounded;
      case Difficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case Difficulty.hard:
        return Icons.local_fire_department_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: difficultyColor.withValues(alpha: 0.4),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                difficultyIcon,
                color: difficultyColor,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.name,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.headingLarge,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${config.pairs} pairs • '
                    '${config.gridSize} × ${config.gridSize} grid',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.headingMedium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: difficultyColor,
            ),
          ],
        ),
      ),
    );
  }
}
