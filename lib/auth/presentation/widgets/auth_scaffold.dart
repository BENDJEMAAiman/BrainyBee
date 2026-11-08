
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final Widget? appBarAction;
  final double appBarHeight;

  const AuthScaffold({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.appBarAction,
    this.appBarHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: AppColors.authBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: appBarHeight.h,

        leading: showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF222222),
                ),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,

        actions: appBarAction != null ? [appBarAction!] : null,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: child,
        ),
      ),
    );
  }
}
