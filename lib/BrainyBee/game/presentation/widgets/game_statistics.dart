
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class GameStatistics extends StatelessWidget {
  final int moves;
  final int elapsedSeconds;
  final int matchedPairs;
  final int totalPairs;

  const GameStatistics({
    super.key,
    required this.moves,
    required this.elapsedSeconds,
    required this.matchedPairs,
    required this.totalPairs,
  });

  String get formattedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatisticItem(
            icon: Icons.touch_app_rounded,
            label: 'Moves',
            value: moves.toString(),
          ),
        ),
        Expanded(
          child: _StatisticItem(
            icon: Icons.timer_rounded,
            label: 'Time',
            value: formattedTime,
          ),
        ),
        Expanded(
          child: _StatisticItem(
            icon: Icons.check_circle_rounded,
            label: 'Pairs',
            value: '$matchedPairs/$totalPairs',
          ),
        ),
      ],
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 6.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.amberMain,
            size: 20.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.headingLarge,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.headingMedium,
            ),
          ),
        ],
      ),
    );
  }
}
