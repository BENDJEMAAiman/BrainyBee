import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_app_project/core/theme/app_text_styles.dart';
import 'package:mobile_app_project/onboarding/presentation/widgets/page_indicator.dart';

class OnboardingItem extends StatelessWidget {
  final String imagePath;
  final String description;
  final int currentPage;
  final int pageCount;

  const OnboardingItem({
    super.key,
    required this.imagePath,
    required this.description,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 80.h),
        SizedBox(
          width: 292.w,
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.headingLarge,
          ),
        ),

        SizedBox(height: 48.h),

        SvgPicture.asset(
          imagePath,
          width: 150.w,
          height: 150.h,
          fit: BoxFit.contain,
        ),

        SizedBox(height: 100.h),

        PageIndicator(currentPage: currentPage, pageCount: pageCount),
      ],
    );
  }
}
