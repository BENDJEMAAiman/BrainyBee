import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Large page titles - Nunito ExtraBold
  static final headingLarge = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 23.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.headingLarge,
    height: 40 / 23,
    letterSpacing: 0,
  );

  /// Medium headings - Nunito SemiBold
  static final headingMedium = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.headingMedium,
    height: 40 / 18,
    letterSpacing: 0,
  );

  /// TextField labels - Inter Medium
  static final textFieldLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textFieldLabel,
    height: 1.0,
    letterSpacing: 0,
  );

  /// Primary button text - Inter Bold
  static final buttonPrimary = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.buttonPrimary,
    height: 18 / 13,
    letterSpacing: 0.8,
  );

  /// Terms and conditions - Inter Medium
  static final termsText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.termsText,
    height: 20 / 14,
    letterSpacing: 0,
  );

  /// Highlighted words inside terms text - Inter Bold
  static final termsHighlight = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.termsHighlight,
    height: 20 / 14,
    letterSpacing: 0,
  );

  /// Privacy information - Inter Medium
  static final privacyText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.privacyText,
    height: 20 / 12,
    letterSpacing: 0,
  );
}
