import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_primary_button.dart';

class OnboardingActions extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onSignIn;

  const OnboardingActions({
    super.key,
    required this.isLastPage,
    required this.onNext,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthPrimaryButton(
          text: isLastPage ? 'Get Started' : 'Next',
          onPressed: isLastPage ? onSignIn : onNext,
        ),

        SizedBox(height: 8.h),
      ],
    );
  }
}
