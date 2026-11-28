import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app_project/auth/business_logic/auth_cubit.dart';
import 'package:mobile_app_project/firebase_options.dart';

import 'package:mobile_app_project/core/dependecy_injection/repositories.dart';
import 'package:mobile_app_project/core/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized!");
    await initializeDependencies();
  } on FirebaseException catch (e) {
    debugPrint('Firebase initialization failed: ${e.message}');
    rethrow;
  } catch (e) {
    debugPrint('Unexpected error during Firebase initialization: $e');
    rethrow;
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return BlocProvider(
              create: (_) => AuthCubit(authRepository),
              child: MaterialApp.router(
                routerConfig: appRouter,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(fontFamily: "Nunito"),
              ),
            );
          },
        );
      },
    );
  }
}
