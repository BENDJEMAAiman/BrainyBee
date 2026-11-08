
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/core/theme/app_text_styles.dart';

class AuthTermsText extends StatefulWidget {
  final bool isSignUp;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  const AuthTermsText({
    super.key,
    this.isSignUp = false,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  @override
  State<AuthTermsText> createState() => _AuthTermsTextState();
}

class _AuthTermsTextState extends State<AuthTermsText> {
  late final TapGestureRecognizer termsRecognizer;
  late final TapGestureRecognizer privacyRecognizer;

  @override
  void initState() {
    super.initState();

    termsRecognizer = TapGestureRecognizer()
      ..onTap = widget.onTermsTap;

    privacyRecognizer = TapGestureRecognizer()
      ..onTap = widget.onPrivacyTap;
  }

  @override
  void didUpdateWidget(covariant AuthTermsText oldWidget) {
    super.didUpdateWidget(oldWidget);

    termsRecognizer.onTap = widget.onTermsTap;
    privacyRecognizer.onTap = widget.onPrivacyTap;
  }

  @override
  void dispose() {
    termsRecognizer.dispose();
    privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Terms and Privacy Policy
          Text.rich(
            TextSpan(
              style: AppTextStyles.termsText,
              children: [
                TextSpan(
                  text: 'By signing ${widget.isSignUp ? 'up' : 'in'} '
                      'to BrainyBee, you agree to our ',
                ),
                TextSpan(
                  text: 'Terms',
                  style: AppTextStyles.termsHighlight,
                  recognizer: termsRecognizer,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTextStyles.termsHighlight,
                  recognizer: privacyRecognizer,
                ),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          // Privacy reassurance
          Text(
            'We only collect the information we need. '
            'Nothing is shared without your consent.',
            style: AppTextStyles.privacyText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
