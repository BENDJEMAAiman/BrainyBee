import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/core/theme/app_text_styles.dart';

class SubHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SubHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headingLarge,
        ),

        SizedBox(height: 8.h),

        Text(
          subtitle,
          style: AppTextStyles.headingMedium,
        ),
      ],
    );
  }
}