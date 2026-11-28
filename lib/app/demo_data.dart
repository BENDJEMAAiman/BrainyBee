import 'package:mobile_app_project/BrainyBee/habits/data/habit_repository.dart';
import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/data/studies_respository.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';

/// Fills an empty app with example data, so a demo does not start with blank
/// pages. It only adds data to a part that is completely empty, so it never
/// touches anything the user created.
class DemoData {
  DemoData._();

  static Future<void> seedIfEmpty({
    required HabitRepository habitRepository,
    required StudiesRepository studiesRepository,
  }) async {
    final habits = await habitRepository.watchHabits().first;
    if (habits.isEmpty) {
      await _seedHabits(habitRepository);
    }

    final timetable = await studiesRepository.watchTimetable().first;
    final homeworks = await studiesRepository.watchHomeworks().first;
    if (timetable.cells.isEmpty && homeworks.isEmpty) {
      await _seedStudies(studiesRepository);
    }
  }

  static Future<void> _seedHabits(HabitRepository repository) async {
    final today = Habit.dateOnly(DateTime.now());
    DateTime ago(int n) => DateTime(today.year, today.month, today.day - n);
    Set<String> doneDaysAgo(List<int> days) => {
      for (final n in days) Habit.dateKey(ago(n)),
    };

    final habits = [
      // 7 days in a row including today: a streak milestone.
      Habit(
        id: '${repository.generateId()}a',
        name: 'Exercise 20 minutes',
        iconKey: 'exercise',
        createdAt: ago(20),
        cycleStart: ago(20),
        completedDates: doneDaysAgo([0, 1, 2, 3, 4, 5, 6]),
      ),
      // A 5-day streak up to yesterday: "streak ends tonight" in the evening.
      Habit(
        id: '${repository.generateId()}b',
        name: 'Sleep at least 7 hours',
        iconKey: 'sleep',
        createdAt: ago(20),
        cycleStart: ago(20),
        completedDates: doneDaysAgo([1, 2, 3, 4, 5]),
      ),
      Habit(
        id: '${repository.generateId()}c',
        name: 'Drink 8 cups of water',
        iconKey: 'water',
        createdAt: ago(3),
        cycleStart: ago(3),
        completedDates: doneDaysAgo([1, 2]),
      ),
      // Its 30-day round is over: "round complete" update.
      Habit(
        id: '${repository.generateId()}d',
        name: 'Read 15 minutes',
        iconKey: 'read',
        createdAt: ago(40),
        cycleStart: ago(33),
        completedDates: doneDaysAgo([0, 8, 9, 12, 15]),
      ),
    ];

    for (final habit in habits) {
      await repository.saveHabit(habit);
    }
  }

  static Future<void> _seedStudies(StudiesRepository repository) async {
    await repository.saveTimetable(
      Timetable(
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
      ),
    );

    final today = Homework.dateOnly(DateTime.now());
    DateTime inDays(int n) => DateTime(today.year, today.month, today.day + n);

    final homeworks = [
      // To do
      Homework(
        id: '${repository.generateId()}a',
        title: 'Exercises 4 to 7, page 52',
        subject: 'Math',
        dueDate: inDays(0),
        createdAt: inDays(-2),
      ),
      Homework(
        id: '${repository.generateId()}b',
        title: 'Read chapter 3',
        subject: 'English',
        dueDate: inDays(1),
        createdAt: inDays(-1),
      ),
      Homework(
        id: '${repository.generateId()}c',
        title: 'Physics lab report',
        subject: 'Physics',
        dueDate: inDays(4),
        createdAt: inDays(-3),
      ),
      // Missed
      Homework(
        id: '${repository.generateId()}d',
        title: 'Chemistry worksheet',
        subject: 'Chemistry',
        dueDate: inDays(-2),
        createdAt: inDays(-6),
      ),
      // Done on time, a few days ago (for the statistics)
      Homework(
        id: '${repository.generateId()}e',
        title: 'Vocabulary list',
        subject: 'English',
        dueDate: inDays(-1),
        createdAt: inDays(-5),
        completedOn: inDays(-2),
      ),
      Homework(
        id: '${repository.generateId()}f',
        title: 'History summary',
        subject: 'History',
        dueDate: inDays(-3),
        createdAt: inDays(-6),
        completedOn: inDays(-3),
      ),
    ];

    for (final homework in homeworks) {
      await repository.saveHomework(homework);
    }
  }
}