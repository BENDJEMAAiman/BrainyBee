import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project/BrainyBee/home/presentation/pages/home_screen.dart';

import 'package:mobile_app_project/auth/presentation/pages/congratulations.dart';
import 'package:mobile_app_project/auth/presentation/pages/sign_in.dart';
import 'package:mobile_app_project/auth/presentation/pages/forgot_password_page.dart';
import 'package:mobile_app_project/auth/presentation/pages/check_email_page.dart';
import 'package:mobile_app_project/auth/presentation/pages/sign_up.dart';
import 'package:mobile_app_project/core/dependecy_injection/repositories.dart';

import 'package:mobile_app_project/core/routing/routes.dart';
import 'package:mobile_app_project/onboarding/business_logic/onboarding_cubit.dart';
import 'package:mobile_app_project/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mobile_app_project/splash/business_logic/splash_cubit.dart';
import 'package:mobile_app_project/splash/presentation/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,

  routes: [
    // Splash
    GoRoute(
      path: Routes.splash,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => SplashCubit(splashRepository),
          child: const SplashPage(),
        );
      },
    ),

    GoRoute(
      path: Routes.onboarding,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => OnboardingCubit(onboardingRepository),
          child: const OnboardingPage(),
        );
      },
    ),

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

    // Check Email
    GoRoute(
      path: Routes.checkEmail,
      builder: (context, state) {
        final email = state.extra as String? ?? '';

        return CheckEmailPage(email: email);
      },
    ),

    // Congratulations
    GoRoute(
      path: Routes.congratulations,
      builder: (context, state) => CongratulationsPage(
        onContinue: () {
          // Add child setup navigation later.
        },
      ),
    ),

    GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
  ],
);
