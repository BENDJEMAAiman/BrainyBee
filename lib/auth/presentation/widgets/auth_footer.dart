
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';
import 'package:mobile_app_project/core/theme/app_text_styles.dart';

class AuthFooter extends StatefulWidget {
  final String message;
  final String actionText;
  final VoidCallback onActionTap;

  const AuthFooter({
    super.key,
    required this.message,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  State<AuthFooter> createState() => _AuthFooterState();
}

class _AuthFooterState extends State<AuthFooter> {
  late final TapGestureRecognizer actionRecognizer;

  @override
  void initState() {
    super.initState();

    actionRecognizer = TapGestureRecognizer()
      ..onTap = widget.onActionTap;
  }

  @override
  void didUpdateWidget(covariant AuthFooter oldWidget) {
    super.didUpdateWidget(oldWidget);

    actionRecognizer.onTap = widget.onActionTap;
  }

  @override
  void dispose() {
    actionRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          style: AppTextStyles.authFooter,
          children: [
            TextSpan(
              text: widget.message,
            ),

            TextSpan(
              text: widget.actionText,
              style: AppTextStyles.authFooter.copyWith(
                color: AppColors.authFooterHighlight,
              ),
              recognizer: actionRecognizer,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
