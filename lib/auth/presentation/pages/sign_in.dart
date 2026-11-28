import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app_project/auth/business_logic/auth_cubit.dart';
import 'package:mobile_app_project/auth/business_logic/auth_state.dart';
import 'package:mobile_app_project/auth/presentation/validators/auth_validators.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_divider.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_footer.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_primary_button.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_scaffold.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_terms_text.dart';
import 'package:mobile_app_project/auth/presentation/widgets/auth_text_field.dart';
import 'package:mobile_app_project/auth/presentation/widgets/google_auth_button.dart';
import 'package:mobile_app_project/core/routing/routes.dart';
import 'package:mobile_app_project/core/theme/app_text_styles.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Submit email and password
  void _signIn() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  // Sign in with Google
  void _signInWithGoogle() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Successful authentication
        if (state is Authenticated) {
          context.go(Routes.home);
        }
        // Email verification required
        else if (state is EmailVerificationRequired) {
          context.go(
            Routes.checkEmail,
            extra: _emailController.text.trim(), // Pass the email here
          );
        }
        // Authentication error
        else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },

      builder: (context, state) {
        final isLoginLoading = state is LoginLoading;
        final isGoogleLoading = state is GoogleLogLoading;

        final isLoading = isLoginLoading || isGoogleLoading;

        return AuthScaffold(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // Header
                Text(
                  'Welcome back!',
                  style: AppTextStyles.headingLarge,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                Text(
                  'Sign in to your parent space to follow your '
                  'child’s progress.',
                  style: AppTextStyles.headingMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 22.h),

                // Email and password fields
                AuthTextField(
                  hintText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.email,
                ),

                SizedBox(height: 8.h),

                AuthTextField(
                  hintText: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  showForgotPassword: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  validator: AuthValidators.password,
                  onForgotPassword: () {
                    context.push(Routes.forgotPassword);
                  },
                ),

                SizedBox(height: 14.h),

                // Sign in button
                AuthPrimaryButton(
                  text: 'CREATE ACCOUNT',
                  isLoading: isLoginLoading,
                  onPressed: isLoading ? null : _signIn,
                ),

                SizedBox(height: 24.h),

                // OR divider
                const AuthDivider(),

                SizedBox(height: 12.h),

                // Google button
                GoogleAuthButton(
                  onPressed: isLoading ? null : _signInWithGoogle,
                ),

                SizedBox(height: 38.h),

                // Terms and privacy
                AuthTermsText(
                  onTermsTap: () {
                    context.push(Routes.terms);
                  },
                  onPrivacyTap: () {
                    context.push(Routes.privacy);
                  },
                ),

                SizedBox(height: 32.h),

                // Sign up footer
                AuthFooter(
                  message: "Don't have an account yet? ",
                  actionText: 'Create a parent account',
                  onActionTap: () {
                    context.push(Routes.signUp);
                  },
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
