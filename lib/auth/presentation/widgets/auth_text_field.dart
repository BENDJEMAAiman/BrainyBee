
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';
import 'package:mobile_app_project/core/theme/app_text_styles.dart';

class AuthTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final bool showForgotPassword;
  final VoidCallback? onForgotPassword;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.showForgotPassword = false,
    this.onForgotPassword,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onChanged,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      obscureText: obscureText,

      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.headingMedium,
      ),

      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyles.textFieldLabel,

        filled: true,
        fillColor: AppColors.textFieldBackground,

        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),

        constraints: BoxConstraints(
          minHeight: 49.h,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: AppColors.textFieldBorder,
            width: 2.w,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: AppColors.textFieldBorder,
            width: 2.w,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: AppColors.textFieldBorder,
            width: 2.w,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2.w,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2.w,
          ),
        ),

        suffixIcon: _buildSuffixIcon(),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    // Forgot password action
    if (widget.showForgotPassword) {
      return TextButton(
        onPressed: widget.onForgotPassword,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'FORGOT?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textFieldLabel,
          ),
        ),
      );
    }

    // Password visibility toggle
    if (widget.isPassword) {
      return IconButton(
        onPressed: () {
          setState(() {
            obscureText = !obscureText;
          });
        },
        icon: Icon(
          obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textFieldLabel,
          size: 21.sp,
        ),
      );
    }

    return null;
  }
}
