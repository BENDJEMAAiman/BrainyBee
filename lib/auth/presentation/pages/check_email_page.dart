
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mobile_app_project/auth/business_logic/auth_cubit.dart';
import 'package:mobile_app_project/auth/business_logic/auth_state.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_scaffold.dart';

import 'package:mobile_app_project/core/theme/app_colors.dart';
import 'package:mobile_app_project/core/theme/app_text_styles.dart';

class CheckEmailPage extends StatelessWidget {
  final String email;

  const CheckEmailPage({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is VerificationEmailSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email sent successfully!'),
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
        final isLoading = state is AuthLoading;

        return AuthScaffold(
          showBackButton: true,
          child: Column(
            children: [
              SizedBox(height: 70.h),

              // Heading
              Text(
                'Check your email',
                style: AppTextStyles.headingLarge,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8.h),

              // Verification message
              Text(
                'We sent a verification link to',
                style: AppTextStyles.headingMedium,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8.h),

              // User email
              Text(
                email,
                style: AppTextStyles.headingMedium,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24.h),

              // Resend message and action
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "If you didn't receive an email? ",
                    style: AppTextStyles.headingMedium,
                  ),

                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                            context
                                .read<AuthCubit>()
                                .sendEmailVerification();
                          },
                    child: Text(
                      isLoading ? 'Sending...' : 'Resend',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.authFooterHighlight,
                      ),
                    ),
                  ),
                ],
              ),

              if (isLoading) ...[
                SizedBox(height: 20.h),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        );
      },
    );
  }
}
