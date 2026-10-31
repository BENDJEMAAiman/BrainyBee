import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';

/// How well the user did on ONE day, across all habits.
class DayProgress {
  const DayProgress({
    required this.date,
    required this.done,
    required this.total,
  });

  final DateTime date;

  /// How many habits were done that day.
  final int done;

  /// How many habits existed that day (habits created later are not counted).
  final int total;

  /// From 0.0 (nothing done) to 1.0 (everything done).
  double get fraction => total == 0 ? 0 : done / total;

  /// The same value as a whole percent, e.g. 60.
  int get percent => (fraction * 100).round();
}

/// Pure calculations for the progress graph. No Flutter code here, so it is
/// easy to test and the Cubit can use it later.
class HabitProgress {
  HabitProgress._();

  /// Progress of all [habits] on a single [day].
  static DayProgress forDay(List<Habit> habits, DateTime day) {
    var done = 0;
    var total = 0;
    for (final habit in habits) {
      // A habit that did not exist yet cannot be missed.
      if (habit.isBeforeCreation(day)) continue;
      total++;
      if (habit.isDoneOn(day)) done++;
    }
    return DayProgress(date: Habit.dateOnly(day), done: done, total: total);
  }

  /// The last [days] days ending on [today], OLDEST FIRST (so the last item
  /// is today).
  static List<DayProgress> lastDays(
    List<Habit> habits,
    DateTime today, {
    int days = 7,
  }) {
    final end = Habit.dateOnly(today);
    return [
      for (var back = days - 1; back >= 0; back--)
        forDay(habits, DateTime(end.year, end.month, end.day - back)),
    ];
  }

  /// Average percent over the days that had at least one habit.
  static int averagePercent(List<DayProgress> days) {
    final counted = days.where((day) => day.total > 0).toList();
    if (counted.isEmpty) return 0;
    final sum = counted.fold<double>(0, (sum, day) => sum + day.fraction);
    return (sum / counted.length * 100).round();
  }
}