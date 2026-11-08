
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class GoogleAuthButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleAuthButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44.h,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.textFieldBorder,
          width: 2.w,
        ),
      ),

      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),

          child: Center(
            child: SvgPicture.asset(
              'assets/google_logo.svg',
              width: 87.w,
              height: 21.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
