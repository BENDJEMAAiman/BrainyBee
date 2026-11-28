import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/habits/data/local_habit_repository.dart';
import 'package:mobile_app_project/BrainyBee/studies/data/local_studies_resposiotry.dart';

import 'package:mobile_app_project/BrainyBee/timer/data/local_timer_repository.dart';
import 'package:mobile_app_project/app/app_router.dart';
import 'package:mobile_app_project/app/demo_data.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The MVP entry point. Run it with:
///
///   flutter run -t lib/main_mvp.dart
///
/// There is NO backend and NO Firebase here: the data lives on the device.
///
/// When true, example habits, a timetable and homework are added on the first
/// run (only into parts that are completely empty).
const bool _seedDemoData = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The three storages are created once and shared by every page.
  final habitRepository = await LocalHabitRepository.create();
  final studiesRepository = await LocalStudiesRepository.create();
  final timerRepository = await LocalTimerRepository.create();

  if (_seedDemoData) {
    await DemoData.seedIfEmpty(
      habitRepository: habitRepository,
      studiesRepository: studiesRepository,
    );
  }

  final router = createAppRouter(
    habitRepository: habitRepository,
    studiesRepository: studiesRepository,
    timerRepository: timerRepository,
  );

  runApp(BrainyBeeApp(router: router));
}

class BrainyBeeApp extends StatelessWidget {
  const BrainyBeeApp({super.key, required this.router});

  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BrainyBee',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.canyon),
        scaffoldBackgroundColor: AppColors.background,
      ),
    );
  }
}