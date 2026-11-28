
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class GameBottomSection extends StatelessWidget {
  final VoidCallback onPause;
  final int points;

  const GameBottomSection({
    super.key,
    required this.onPause,
    this.points = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: AppColors.amberMain,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  '$points points',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        ElevatedButton.icon(
          onPressed: onPause,
          icon: const Icon(Icons.pause_rounded),
          label: const Text('Pause'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amberMain,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 14.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      ],
    );
  }
}
