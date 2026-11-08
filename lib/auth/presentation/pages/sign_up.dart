
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



class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Validate and create account
  void _signUp() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().signUpWithEmail(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  // Sign up with Google
  void _signUpWithGoogle() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  // Confirm password validator
  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Account created successfully
        if (state is Authenticated) {
          context.go(Routes.signUp);
        }

        // Email verification required
        else if (state is EmailVerificationRequired) {
          context.go(Routes.checkEmail);
        }

        // Authentication error
        else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      builder: (context, state) {
        final isSignUpLoading = state is SignUpLoading;
        final isGoogleLoading = state is GoogleLogLoading;

        final isLoading = isSignUpLoading || isGoogleLoading;

        return AuthScaffold(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // Header
                Text(
                  'Create your parent space',
                  style: AppTextStyles.headingLarge,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                Text(
                  'You manage, your child learns and plays safely.',
                  style: AppTextStyles.headingMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 22.h),

                // Name
                AuthTextField(
                  hintText: 'Name',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.fullName,
                ),

                SizedBox(height: 8.h),

                // Email
                AuthTextField(
                  hintText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.email,
                ),

                SizedBox(height: 8.h),

                // Password
                AuthTextField(
                  hintText: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.password,
                ),

                SizedBox(height: 8.h),

                // Confirm Password
                AuthTextField(
                  hintText: 'Confirm Password',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  validator: _confirmPasswordValidator,
                ),

                SizedBox(height: 14.h),

                // Create account button
                AuthPrimaryButton(
                  text: 'CREATE ACCOUNT',
                  isLoading: isSignUpLoading,
                  onPressed: isLoading ? null : _signUp,
                ),

                SizedBox(height: 24.h),

                // OR divider
                const AuthDivider(),

                SizedBox(height: 12.h),

                // Google button
                GoogleAuthButton(
                  onPressed: isLoading ? null : _signUpWithGoogle,
                ),

                SizedBox(height: 38.h),

                // Terms and privacy
                AuthTermsText(
                  isSignUp: true,
                  onTermsTap: () {
                    context.push(Routes.terms);
                  },
                  onPrivacyTap: () {
                    context.push(Routes.privacy);
                  },
                ),

                SizedBox(height: 32.h),

                // Login footer
                AuthFooter(
                  message: 'Already have an account? ',
                  actionText: 'Log in',
                  onActionTap: () {
                    context.go('/sign-in');
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
