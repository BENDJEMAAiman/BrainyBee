import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import firebase_core

import 'package:mobile_app_project/auth/business_logic/auth_cubit.dart';
import 'package:mobile_app_project/core/dependecy_injection/repositories.dart';
import 'package:mobile_app_project/core/routing/app_router.dart';

void main() async { // 2. Make main async
  WidgetsFlutterBinding.ensureInitialized();
  
  // 3. Initialize Firebase before any Firebase services are accessed
  await Firebase.initializeApp(); 
  
  // Note: If you configured Firebase using the FlutterFire CLI, use this instead:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => AuthCubit(authRepository),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
          ),
        );
      },
    );
  }
}