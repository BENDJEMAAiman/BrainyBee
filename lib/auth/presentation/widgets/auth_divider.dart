
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.h,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.h,
              color: AppColors.textFieldBorder,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              'OR',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textFieldLabel,
              ),
            ),
          ),

          Expanded(
            child: Container(
              height: 1.h,
              color: AppColors.textFieldBorder,
            ),
          ),
        ],
      ),
    );
  }
}
