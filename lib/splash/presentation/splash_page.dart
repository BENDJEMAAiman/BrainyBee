import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app_project/auth/business_logic/auth_cubit.dart';
import 'package:mobile_app_project/auth/business_logic/auth_state.dart';
import 'package:mobile_app_project/core/constants/app_assets.dart';
import 'package:mobile_app_project/core/routing/routes.dart';
import 'package:mobile_app_project/splash/business_logic/splash_cubit.dart';
import 'package:mobile_app_project/splash/business_logic/splash_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    context.read<SplashCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SplashCubit, SplashState>(
          listener: (context, state) {
            if (state is NavigateToOnboarding) {
              context.go(Routes.onboarding);
            }

            if (state is CheckAuthentication) {
              context.read<AuthCubit>().checkAuthStatus();
            }
          },
        ),

        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.go(Routes.home);
            }

            if (state is Unauthenticated) {
              context.go(Routes.signIn);
            }

            if (state is EmailVerificationRequired) {
              context.go(Routes.checkEmail, extra: state.user.email);
            }
          },
        ),
      ],

      child: Scaffold(
        backgroundColor: const Color(0xFFFFE68A),
        body: SizedBox.expand(
          child: SvgPicture.asset(AppAssets.splash, fit: BoxFit.fill),
        ),
      ),
    );
  }
}
