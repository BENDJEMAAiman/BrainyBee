import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/habits/data/habit_repository.dart';
import 'package:mobile_app_project/BrainyBee/habits/data/local_habit_repository.dart';
import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/habits_page.dart';

/// TEMPORARY file: delete it when the Habits page is connected to the router.
/// Run it with:  flutter run -t lib/habit_preview.dart -d chrome --web-port 5000
/// (A fixed port makes Chrome keep your saved habits between runs.)

/// When true, three demo habits are added if there are no habits at all.
const bool _seedDemoData = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = await LocalHabitRepository.create();
  if (_seedDemoData) {
    await _seedIfEmpty(repository);
  }

  runApp(_PreviewApp(repository: repository));
}

Future<void> _seedIfEmpty(HabitRepository repository) async {
  final existing = await repository.watchHabits().first;
  if (existing.isNotEmpty) return;

  final today = Habit.dateOnly(DateTime.now());
  DateTime ago(int n) => DateTime(today.year, today.month, today.day - n);
  Set<String> keys(List<int> daysAgo) => {
    for (final n in daysAgo) Habit.dateKey(ago(n)),
  };

  final demoHabits = [
    // In the middle of a round, with a streak.
    Habit(
      id: repository.generateId(),
      name: 'Exercise 20 minutes',
      iconKey: 'exercise',
      createdAt: ago(20),
      cycleStart: ago(20),
      completedDates: keys([0, 1, 2, 3, 5, 6, 9, 12]),
    ),
    // The 30 days are over, so the "New round" button is highlighted.
    Habit(
      id: '${repository.generateId()}b',
      name: 'Sleep at least 7 hours',
      iconKey: 'sleep',
      createdAt: ago(40),
      cycleStart: ago(33),
      completedDates: keys([4, 5, 6, 8, 9, 10, 11, 15, 16, 20, 21, 22, 25, 30]),
    ),
    // A brand-new habit.
    Habit(
      id: '${repository.generateId()}c',
      name: 'Drink 8 cups of water',
      iconKey: 'water',
      createdAt: ago(3),
      cycleStart: ago(3),
      completedDates: keys([1, 2]),
    ),
  ];

  for (final habit in demoHabits) {
    await repository.saveHabit(habit);
  }
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp({required this.repository});

  final HabitRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HabitsPage(repository: repository),
    );
  }
}