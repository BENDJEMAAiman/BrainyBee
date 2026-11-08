
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';
import 'package:mobile_app_project/core/theme/app_text_styles.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        width: double.infinity,
        height: 46.h,

        decoration: BoxDecoration(
          color: AppColors.primaryButtonBackground,
          borderRadius: BorderRadius.circular(16.r),

          boxShadow: [
            BoxShadow(
              color: AppColors.primaryButtonShadow,
              offset: Offset(0, 4.h),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),

        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(16.r),

            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      text,
                      style: AppTextStyles.buttonPrimary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
