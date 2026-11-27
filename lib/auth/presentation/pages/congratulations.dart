
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_primary_button.dart';

import 'package:mobile_app_project/auth/presentation/widgets/auth_scaffold.dart';
import 'package:mobile_app_project/core/constants/app_assets.dart';

import 'package:mobile_app_project/core/theme/app_text_styles.dart';

class CongratulationsPage extends StatelessWidget {
  final VoidCallback onContinue;

  const CongratulationsPage({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),

          // Heading
          Text(
            'Congratulations!',
            style: AppTextStyles.headingLarge,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12.h),

          // Description
          Text(
            "Your parent account is ready, let's get "
            'BrainyBee set up for your child!',
            style: AppTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 50.h),

          // Congratulations illustration
          SvgPicture.asset(
            AppAssets.congratulations,
            width: 200.w,
            height: 200.h,
            fit: BoxFit.contain,
          ),

          SizedBox(height: 60.h),

          // Continue button
          AuthPrimaryButton(
            text: "Let's Get Started",
            onPressed: onContinue,
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
