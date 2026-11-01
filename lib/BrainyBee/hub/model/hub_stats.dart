import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/widgets/habit_progress.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';

/// How well one habit did over the last 7 days.
class HabitRate {
  const HabitRate({
    required this.name,
    required this.percent,
    required this.doneDays,
    required this.activeDays,
  });

  final String name;

  /// Done days out of the days the habit existed, in percent.
  final int percent;
  final int doneDays;

  /// Days of the last 7 on which the habit existed.
  final int activeDays;
}

/// The habit numbers of the last 7 days.
class HabitStats {
  const HabitStats({
    required this.weekPercent,
    required this.bestStreak,
    required this.perfectDays,
    required this.daysWithHabits,
    required this.days,
    required this.rates,
  });

  /// Average daily completion, in percent.
  final int weekPercent;

  /// The longest current streak among all habits (in days).
  final int bestStreak;

  /// Days on which every habit was done.
  final int perfectDays;

  /// Days that had at least one habit (the "out of" for [perfectDays]).
  final int daysWithHabits;

  /// One entry per day, oldest first (the last one is today).
  final List<DayProgress> days;

  /// One entry per habit, best first.
  final List<HabitRate> rates;
}

/// The number of homework tasks finished on one day.
class DayCount {
  const DayCount({required this.date, required this.count});

  final DateTime date;
  final int count;
}

/// The homework numbers of the last 7 days.
class HomeworkStats {
  const HomeworkStats({
    required this.doneLast7Days,
    required this.todoCount,
    required this.lateNow,
    required this.onTimePercent,
    required this.donePerDay,
  });

  /// Homework marked done in the last 7 days.
  final int doneLast7Days;

  /// Homework not done and not late yet.
  final int todoCount;

  /// Homework that is late right now.
  final int lateNow;

  /// Share of the homework due in the last 7 days that was finished on or
  /// before its due date, in percent. Null when there is nothing to measure.
  final int? onTimePercent;

  /// Tasks finished on each of the last 7 days, oldest first (the last one is
  /// today).
  final List<DayCount> donePerDay;

  /// All the tasks shown in the status donut.
  int get total => doneLast7Days + todoCount + lateNow;
}

/// All the statistics of the main page. Pure calculation, no Flutter code.
///
/// A part is null when there is nothing to show (no habits, or no homework at
/// all), so the screen can simply leave it out.
class HubStats {
  const HubStats({required this.habits, required this.homework});

  factory HubStats.from({
    required List<Habit> habits,
    required List<Homework> homeworks,
    required DateTime now,
  }) {
    return HubStats(
      habits: _habitStats(habits, now),
      homework: _homeworkStats(homeworks, now),
    );
  }

  final HabitStats? habits;
  final HomeworkStats? homework;

  bool get hasAny => habits != null || homework != null;

  static HabitStats? _habitStats(List<Habit> habits, DateTime now) {
    if (habits.isEmpty) return null;

    final today = Habit.dateOnly(now);
    final days = HabitProgress.lastDays(habits, today);

    var bestStreak = 0;
    for (final habit in habits) {
      final streak = habit.currentStreak(today);
      if (streak > bestStreak) bestStreak = streak;
    }

    // How each habit did over the same 7 days.
    final rates = <HabitRate>[];
    for (final habit in habits) {
      var active = 0;
      var done = 0;
      for (final day in days) {
        if (habit.isBeforeCreation(day.date)) continue;
        active++;
        if (habit.isDoneOn(day.date)) done++;
      }
      if (active == 0) continue;
      rates.add(
        HabitRate(
          name: habit.name,
          percent: (done / active * 100).round(),
          doneDays: done,
          activeDays: active,
        ),
      );
    }
    rates.sort((a, b) {
      final byPercent = b.percent.compareTo(a.percent);
      if (byPercent != 0) return byPercent;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return HabitStats(
      weekPercent: HabitProgress.averagePercent(days),
      bestStreak: bestStreak,
      perfectDays: days
          .where((day) => day.total > 0 && day.done == day.total)
          .length,
      daysWithHabits: days.where((day) => day.total > 0).length,
      days: days,
      rates: rates,
    );
  }

  static HomeworkStats? _homeworkStats(List<Homework> homeworks, DateTime now) {
    if (homeworks.isEmpty) return null;

    final today = Homework.dateOnly(now);
    final windowStart = DateTime(today.year, today.month, today.day - 6);
    final groups = HomeworkGroups.from(homeworks, now);

    // Tasks finished on each of the last 7 days.
    final donePerDay = <DayCount>[];
    for (var back = 6; back >= 0; back--) {
      final day = DateTime(today.year, today.month, today.day - back);
      var count = 0;
      for (final homework in homeworks) {
        final completed = homework.completedOn;
        if (completed != null && Homework.dateOnly(completed) == day) {
          count++;
        }
      }
      donePerDay.add(DayCount(date: day, count: count));
    }
    final doneLast7Days = donePerDay.fold<int>(
      0,
      (sum, day) => sum + day.count,
    );

    // "On time" looks at the homework that was DUE in the last 7 days.
    var counted = 0;
    var onTime = 0;
    for (final homework in homeworks) {
      final rawCompleted = homework.completedOn;
      final completed = rawCompleted == null
          ? null
          : Homework.dateOnly(rawCompleted);

      final due = Homework.dateOnly(homework.dueDate);
      final dueInWindow = !due.isBefore(windowStart) && !due.isAfter(today);
      if (!dueInWindow) continue;

      // Homework due today and not done yet is not judged (the day is not
      // over), so the rate does not drop during the day.
      final dueHasPassed = due.isBefore(today);
      if (!dueHasPassed && completed == null) continue;

      counted++;
      if (completed != null && !completed.isAfter(due)) {
        onTime++;
      }
    }

    return HomeworkStats(
      doneLast7Days: doneLast7Days,
      todoCount: groups.todo.length,
      lateNow: groups.missed.length,
      onTimePercent: counted == 0 ? null : (onTime / counted * 100).round(),
      donePerDay: donePerDay,
    );
  }
}