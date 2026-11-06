import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_project/BrainyBee/quiz/presentation/pages/quiz_api_test_screen.dart';
import 'package:mobile_app_project/core/dependecy_injection/dependency_injection.dart';
import 'package:mobile_app_project/core/dependecy_injection/repositories.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  DependencyInjection.init();

  runApp(
    BlocProvider(
      create: (_) => Repositories.createQuizCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.amber,
          ),
        ),
        home: const QuizApiTestScreen(),
      ),
    ),
  );
}
