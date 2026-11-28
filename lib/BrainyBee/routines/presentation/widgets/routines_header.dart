import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app_project/BrainyBee/home/presentation/widgets/sub_header.dart';
import 'package:mobile_app_project/core/constants/app_assets.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class RoutinesHeader extends StatelessWidget {
  const RoutinesHeader({super.key});

 

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AppAssets.brainyIcon,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
            ),

            SizedBox(width: 6.w),

            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Brainy',
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amberMain,
                    ),
                  ),
                  TextSpan(
                    text: 'Bee',
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brainyLogo,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SvgPicture.asset(
              AppAssets.flameIcon,
              width: 28.w,
              height: 28.h,
              fit: BoxFit.contain,
            ),

            SizedBox(width: 24.w),

            SvgPicture.asset(
              AppAssets.heartIcon,
              width: 28.w,
              height: 28.h,
              fit: BoxFit.contain,
            ),

            
          ],
        ),

        SizedBox(height: 24.h),

        const SubHeader(
          title: "My Habits!",
          subtitle: "check off your habits today!",
        ),
      ],
    );
  }
}
