import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project/BrainyBee/game/presentation/pages/flip_match_page.dart';
import 'package:mobile_app_project/BrainyBee/home/presentation/pages/home_screen.dart';
import 'package:mobile_app_project/BrainyBee/presentation/pages/brainybee_shell_screen.dart';
import 'package:mobile_app_project/BrainyBee/profile/presentation/pages/profile_screen.dart';
import 'package:mobile_app_project/BrainyBee/quiz/presentation/pages/quiz_screen.dart';
import 'package:mobile_app_project/BrainyBee/routines/presentation/pages/routines_screen.dart';

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
    // Main application shell
    ShellRoute(
      builder: (context, state, child) {
        return BrainyShellScreen(location: state.uri.toString(), child: child);
      },
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.routines,
          builder: (context, state) => const RoutinesScreen(),
        ),
        GoRoute(
          path: Routes.quiz,
          builder: (context, state) => const QuizScreen(),
        ),
        GoRoute(
          path: Routes.game,
          builder: (context, state) => const FlipMatchPage(),
        ),
        GoRoute(
          path: Routes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

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

    // Onboarding
    GoRoute(
      path: Routes.onboarding,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => OnboardingCubit(onboardingRepository),
          child: const OnboardingPage(),
        );
      },
    ),

    // Authentication
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: Routes.signUp,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: Routes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    // Email
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
          context.go(Routes.home);
        },
      ),
    ),
  ],
);
