import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/hub/model/hub_stats.dart';
import 'package:mobile_app_project/BrainyBee/hub/model/hub_summary.dart';
import 'package:mobile_app_project/BrainyBee/hub/model/hub_updates.dart';
import 'package:mobile_app_project/BrainyBee/hub/presentation/hub_screen.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';

/// TEMPORARY file: delete it when the hub is connected to the router.
/// Run it with:  flutter run -t lib/hub_preview.dart -d chrome --web-port 5000

/// To test other moments, put a fixed date here instead of null:
///  - DateTime(2026, 11, 1, 9, 30)   Sunday morning: "Now" class, no evening
///                                   updates.
///  - DateTime(2026, 11, 1, 19, 0)   Sunday evening: "habits still to do" and
///                                   "streak ends tonight" appear.
///  - DateTime(2026, 11, 6, 10, 0)   Friday: no school, next class is Sunday.
/// Remember to put null back afterwards.
final DateTime? _fixedNow = null;

void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _PreviewPage(),
    );
  }
}

class _PreviewPage extends StatelessWidget {
  const _PreviewPage();

  void _say(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final now = _fixedNow ?? DateTime.now();
    final today = Habit.dateOnly(now);
    DateTime inDays(int n) => DateTime(today.year, today.month, today.day + n);
    Set<String> doneOn(List<int> offsets) => {
      for (final n in offsets) Habit.dateKey(inDays(n)),
    };

    // Made-up habits.
    final habits = [
      // 7 days in a row, including today: a streak milestone.
      Habit(
        id: '1',
        name: 'Exercise 20 minutes',
        iconKey: 'exercise',
        createdAt: inDays(-20),
        cycleStart: inDays(-20),
        completedDates: doneOn([0, -1, -2, -3, -4, -5, -6]),
      ),
      // A 5-day streak up to yesterday, not done today: at risk in the evening.
      Habit(
        id: '2',
        name: 'Sleep at least 7 hours',
        iconKey: 'sleep',
        createdAt: inDays(-20),
        cycleStart: inDays(-20),
        completedDates: doneOn([-1, -2, -3, -4, -5]),
      ),
      Habit(
        id: '3',
        name: 'Drink 8 cups of water',
        iconKey: 'water',
        createdAt: inDays(-3),
        cycleStart: inDays(-3),
        completedDates: doneOn([-1]),
      ),
      // Its 30-day round is over: "round complete" update.
      Habit(
        id: '4',
        name: 'Read 15 minutes',
        iconKey: 'read',
        createdAt: inDays(-40),
        cycleStart: inDays(-33),
        completedDates: doneOn([0, -8, -9, -12, -15]),
      ),
    ];

    final timetable = Timetable(
      cells: {
        Timetable.cellKey(0, 0): 'Math',
        Timetable.cellKey(0, 1): 'Math',
        Timetable.cellKey(0, 2): 'Physics',
        Timetable.cellKey(0, 4): 'English',
        Timetable.cellKey(1, 0): 'Arabic',
        Timetable.cellKey(1, 1): 'Chemistry',
        Timetable.cellKey(1, 5): 'Sport',
        Timetable.cellKey(2, 2): 'Math',
        Timetable.cellKey(2, 3): 'History',
        Timetable.cellKey(3, 0): 'Physics',
        Timetable.cellKey(3, 4): 'English',
        Timetable.cellKey(4, 1): 'Biology',
        Timetable.cellKey(4, 2): 'Biology',
      },
    );

    final homeworks = [
      // Due today, not done.
      Homework(
        id: '1',
        title: 'Exercises 4 to 7, page 52',
        subject: 'Math',
        dueDate: inDays(0),
        createdAt: inDays(-2),
      ),
      // Due later.
      Homework(
        id: '2',
        title: 'Read chapter 3',
        subject: 'English',
        dueDate: inDays(2),
        createdAt: inDays(-1),
      ),
      // Late.
      Homework(
        id: '3',
        title: 'Chemistry worksheet',
        subject: 'Chemistry',
        dueDate: inDays(-2),
        createdAt: inDays(-6),
      ),
      // Done on time.
      Homework(
        id: '4',
        title: 'Vocabulary list',
        subject: 'English',
        dueDate: inDays(-1),
        createdAt: inDays(-5),
        completedOn: inDays(-2),
      ),
      Homework(
        id: '5',
        title: 'History summary',
        subject: 'History',
        dueDate: inDays(-3),
        createdAt: inDays(-6),
        completedOn: inDays(-3),
      ),
      // Done, but after its due date.
      Homework(
        id: '6',
        title: 'Essay draft',
        subject: 'Arabic',
        dueDate: inDays(-4),
        createdAt: inDays(-8),
        completedOn: inDays(-2),
      ),
      // Old: outside the 7-day window, so it is not counted.
      Homework(
        id: '7',
        title: 'Old finished task',
        subject: 'Math',
        dueDate: inDays(-20),
        createdAt: inDays(-25),
        completedOn: inDays(-20),
      ),
    ];

    return HubScreen(
      summary: HubSummary.from(
        habits: habits,
        timetable: timetable,
        homeworks: homeworks,
        now: now,
      ),
      updates: HubUpdates.build(habits: habits, homeworks: homeworks, now: now),
      stats: HubStats.from(habits: habits, homeworks: homeworks, now: now),
      now: now,
      onOpenHabits: () => _say(context, 'The Habits page opens here.'),
      onOpenStudies: () => _say(context, 'The Studies page opens here.'),
      onStartFocus: () => _say(context, 'The timer page opens here.'),
    );
  }
}