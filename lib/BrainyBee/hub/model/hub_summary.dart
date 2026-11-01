import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/widgets/habit_progress.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';

/// The class happening now, or the next one in the timetable.
class UpcomingClass {
  const UpcomingClass({
    required this.subject,
    required this.dayIndex,
    required this.slotIndex,
    required this.isNow,
    required this.daysAhead,
  });

  final String subject;

  /// Column in the timetable (0 = Sunday ... 4 = Thursday).
  final int dayIndex;

  /// Row in the timetable (0 = first session of the day).
  final int slotIndex;

  /// True if the session is happening in the current hour.
  final bool isNow;

  /// 0 = today, 1 = tomorrow, and so on.
  final int daysAhead;

  /// When it is, as text: "Now · 9–10", "Today · 13–14", "Tomorrow · 8–9" or
  /// "Sunday · 8–9".
  String get whenText {
    final slot = TimetableLayout.slotLabel(slotIndex);
    if (isNow) return 'Now · $slot';
    if (daysAhead == 0) return 'Today · $slot';
    if (daysAhead == 1) return 'Tomorrow · $slot';
    return '${TimetableLayout.dayNames[dayIndex]} · $slot';
  }
}

/// The few numbers the main page shows. A pure calculation over the data of
/// the other pages: no Flutter code, so it is easy to test and a Cubit can use
/// it later.
class HubSummary {
  const HubSummary({
    required this.habitsDone,
    required this.habitsTotal,
    required this.upcomingClass,
    required this.homeworkDueToday,
    required this.homeworkMissed,
  });

  /// Works everything out for the moment [now].
  factory HubSummary.from({
    required List<Habit> habits,
    required Timetable timetable,
    required List<Homework> homeworks,
    required DateTime now,
  }) {
    final habitsToday = HabitProgress.forDay(habits, now);
    final groups = HomeworkGroups.from(homeworks, now);

    return HubSummary(
      habitsDone: habitsToday.done,
      habitsTotal: habitsToday.total,
      upcomingClass: _findUpcomingClass(timetable, now),
      homeworkDueToday: groups.todo
          .where((homework) => homework.daysUntilDue(now) == 0)
          .length,
      homeworkMissed: groups.missed.length,
    );
  }

  /// Habits marked done today.
  final int habitsDone;

  /// Habits that exist today (a habit created later is not counted).
  final int habitsTotal;

  /// The current or next class, or null if the timetable is empty.
  final UpcomingClass? upcomingClass;

  /// Homework that is not done and due today.
  final int homeworkDueToday;

  /// Homework that is not done and already late.
  final int homeworkMissed;

  /// Looks for the class happening now or the next filled cell of the
  /// timetable, starting from today and looking up to a week ahead.
  static UpcomingClass? _findUpcomingClass(Timetable timetable, DateTime now) {
    for (var offset = 0; offset <= 7; offset++) {
      final date = DateTime(now.year, now.month, now.day + offset);
      final day = TimetableLayout.dayIndexFor(date);
      if (day == null) continue; // Friday or Saturday: no school.

      for (var slot = 0; slot < TimetableLayout.slotCount; slot++) {
        final subject = timetable.subjectAt(day, slot);
        if (subject.isEmpty) continue;

        if (offset == 0) {
          final startHour = TimetableLayout.slotStartHours[slot];
          if (now.hour > startHour) continue; // Already over today.
          return UpcomingClass(
            subject: subject,
            dayIndex: day,
            slotIndex: slot,
            isNow: now.hour == startHour,
            daysAhead: 0,
          );
        }

        return UpcomingClass(
          subject: subject,
          dayIndex: day,
          slotIndex: slot,
          isNow: false,
          daysAhead: offset,
        );
      }
    }
    return null;
  }
}