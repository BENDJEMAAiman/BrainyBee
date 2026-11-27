import 'package:go_router/go_router.dart';


import 'package:mobile_app_project/auth/presentation/pages/sign_in.dart';
import 'package:mobile_app_project/auth/presentation/pages/forgot_password_page.dart';
import 'package:mobile_app_project/auth/presentation/pages/check_email_page.dart';
import 'package:mobile_app_project/auth/presentation/pages/sign_up.dart';
import 'package:mobile_app_project/core/routing/routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.signIn,

  routes: [
    // Sign In
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => const SignInPage(),
    ),

    // Sign Up
    GoRoute(
      path: Routes.signUp,
      builder: (context, state) => const SignUpPage(),
    ),

    // Forgot Password
    GoRoute(
      path: Routes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    // Check Email - Account Verification
    GoRoute(
      path: Routes.checkEmail,
      builder: (context, state) {
        final email = state.extra as String? ?? '';

        return CheckEmailPage(email: email);
      },
    ),
  ],
);