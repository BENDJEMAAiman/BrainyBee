import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app_project/auth/business_logic/auth_cubit.dart';
import 'package:mobile_app_project/auth/business_logic/auth_state.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_scaffold.dart';
import 'package:mobile_app_project/core/routing/routes.dart';

import 'package:mobile_app_project/core/theme/app_colors.dart';
import 'package:mobile_app_project/core/theme/app_text_styles.dart';

import 'package:mobile_app_project/auth/presentation/widgets/auth_primary_button.dart';

class CheckEmailPage extends StatelessWidget {
  final String email;

  const CheckEmailPage({super.key, required this.email});

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
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }

        if (state is EmailVerificationRequired) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Your email is not verified yet. Please check your inbox.',
              ),
            ),
          );
        }

        if (state is Authenticated) {
          context.go(Routes.congratulations);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AuthScaffold(
          showBackButton: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),

              // Heading
              Text(
                'Check your email',
                style: AppTextStyles.headingLarge,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // Verification message
              Text(
                'We sent a verification link to',
                style: AppTextStyles.headingMedium,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 6.h),

              // Display the actual email used in the sign-up process
              Text(
                email,
                style: AppTextStyles.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              // Resend message and action row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "If you didn't receive an email? ",
                    style: AppTextStyles.headingMedium,
                  ),
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                            context.read<AuthCubit>().sendEmailVerification();
                          },
                    child: Text(
                      isLoading ? 'Sending...' : 'Resend',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.authFooterHighlight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              if (isLoading) ...[
                SizedBox(height: 24.h),
                const CircularProgressIndicator(),
              ],

              SizedBox(height: 32.h),

              AuthPrimaryButton(
                text: "I've Verified",
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<AuthCubit>().checkAuthStatus();
                      },
              ),
            ],
          ),
        );
      },
    );
  }
}
