
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mobile_app_project/auth/business_logic/auth_cubit.dart';
import 'package:mobile_app_project/auth/business_logic/auth_state.dart';
import 'package:mobile_app_project/auth/presentation/validators/auth_validators.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_primary_button.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_scaffold.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_text_field.dart';


import 'package:mobile_app_project/core/theme/app_text_styles.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().resetPassword(
      _emailController.text.trim(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetEmailSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Password reset instructions have been sent to your email.',
              ),
            ),
          );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ResetPassLoading;

        return AuthScaffold(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 70.h),

                // Heading
                Text(
                  'Forgot password',
                  style: AppTextStyles.headingLarge,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                // Description
                Text(
                  'We will send you instructions on how to reset '
                  'your password by email.',
                  style: AppTextStyles.headingMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

                // Email field
                AuthTextField(
                  hintText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: AuthValidators.email,
                ),

                SizedBox(height: 10.h),

                // Submit button
                AuthPrimaryButton(
                  text: 'SUBMIT',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
