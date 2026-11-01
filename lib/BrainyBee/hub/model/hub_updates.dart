import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';

/// How an update looks and feels.
enum UpdateTone {
  /// Needs action (red).
  alert,

  /// A heads-up (warm yellow).
  info,

  /// Good news (green).
  success,
}

/// Which page tapping an update opens.
enum UpdateTarget { habits, studies, none }

/// One line in the "Latest updates" block.
class HubUpdate {
  const HubUpdate({
    required this.text,
    required this.tone,
    required this.target,
    required this.priority,
  });

  final String text;
  final UpdateTone tone;
  final UpdateTarget target;

  /// Lower numbers are more important and come first.
  final int priority;
}

/// Works out which updates to show, from the data of the other pages.
///
/// Nothing is stored: every update exists only while its condition is true, so
/// it disappears by itself once the user fixes the problem. This is a pure
/// calculation (no Flutter code), so it is easy to test and a Cubit can use it
/// later.
class HubUpdates {
  HubUpdates._();

  /// From this hour on, the "evening" updates appear. (Showing "you have not
  /// ticked your habits" at 7 in the morning would just be nagging.)
  static const int eveningHour = 18;

  /// The most updates shown at once, so the main page stays calm.
  static const int maxShown = 3;

  /// Streak lengths that deserve a "well done".
  static const List<int> streakMilestones = [3, 7, 14, 30, 60, 100];

  static List<HubUpdate> build({
    required List<Habit> habits,
    required List<Homework> homeworks,
    required DateTime now,
  }) {
    final today = Habit.dateOnly(now);
    final groups = HomeworkGroups.from(homeworks, now);
    final isEvening = now.hour >= eveningHour;

    // Habits that already exist today, and which of them are not done yet.
    final activeHabits = habits
        .where((habit) => !habit.isBeforeCreation(today))
        .toList();
    final notDone = activeHabits
        .where((habit) => !habit.isDoneOn(today))
        .toList();

    final updates = <HubUpdate>[];

    // 0) Late homework (red).
    final missedCount = groups.missed.length;
    if (missedCount > 0) {
      updates.add(
        HubUpdate(
          text: missedCount == 1
              ? '1 homework task is late'
              : '$missedCount homework tasks are late',
          tone: UpdateTone.alert,
          target: UpdateTarget.studies,
          priority: 0,
        ),
      );
    }

    // 1) A good streak that ends tonight if the habit is not ticked.
    if (isEvening) {
      Habit? riskiest;
      var longest = 0;
      for (final habit in notDone) {
        // With today not done, this counts the days up to yesterday.
        final streak = habit.currentStreak(today);
        if (streak >= 3 && streak > longest) {
          longest = streak;
          riskiest = habit;
        }
      }
      final risky = riskiest;
      if (risky != null) {
        updates.add(
          HubUpdate(
            text: 'Your $longest-day streak on ${risky.name} ends tonight',
            tone: UpdateTone.info,
            target: UpdateTarget.habits,
            priority: 1,
          ),
        );
      }
    }

    // 2) Homework due today.
    final dueToday = groups.todo
        .where((homework) => homework.daysUntilDue(now) == 0)
        .toList();
    if (dueToday.length == 1) {
      final homework = dueToday.first;
      updates.add(
        HubUpdate(
          text: homework.subject.isEmpty
              ? '"${homework.title}" is due today'
              : '${homework.subject} homework is due today',
          tone: UpdateTone.info,
          target: UpdateTarget.studies,
          priority: 2,
        ),
      );
    } else if (dueToday.length > 1) {
      updates.add(
        HubUpdate(
          text: '${dueToday.length} homework tasks are due today',
          tone: UpdateTone.info,
          target: UpdateTarget.studies,
          priority: 2,
        ),
      );
    }

    // 3) Habits still to do (evening only).
    if (isEvening && notDone.isNotEmpty) {
      updates.add(
        HubUpdate(
          text: notDone.length == 1
              ? '1 habit still to do today'
              : '${notDone.length} habits still to do today',
          tone: UpdateTone.info,
          target: UpdateTarget.habits,
          priority: 3,
        ),
      );
    }

    // 4) A 30-day round is over.
    final finishedRounds = habits
        .where((habit) => habit.isCycleFinished(today))
        .toList();
    if (finishedRounds.length == 1) {
      updates.add(
        HubUpdate(
          text:
              'Your ${Habit.cycleLength}-day round for '
              '${finishedRounds.first.name} is complete',
          tone: UpdateTone.info,
          target: UpdateTarget.habits,
          priority: 4,
        ),
      );
    } else if (finishedRounds.length > 1) {
      updates.add(
        HubUpdate(
          text: '${finishedRounds.length} habit rounds are complete',
          tone: UpdateTone.info,
          target: UpdateTarget.habits,
          priority: 4,
        ),
      );
    }

    // 5) A streak milestone reached today (the highest one, if several).
    Habit? milestoneHabit;
    var milestone = 0;
    for (final habit in activeHabits) {
      if (!habit.isDoneOn(today)) continue;
      final streak = habit.currentStreak(today);
      if (streakMilestones.contains(streak) && streak > milestone) {
        milestone = streak;
        milestoneHabit = habit;
      }
    }
    final celebrated = milestoneHabit;
    if (celebrated != null) {
      updates.add(
        HubUpdate(
          text: '$milestone days in a row on ${celebrated.name}!',
          tone: UpdateTone.success,
          target: UpdateTarget.habits,
          priority: 5,
        ),
      );
    }

    // 6) Every habit is done.
    if (activeHabits.isNotEmpty && notDone.isEmpty) {
      updates.add(
        const HubUpdate(
          text: 'All habits done today',
          tone: UpdateTone.success,
          target: UpdateTarget.habits,
          priority: 6,
        ),
      );
    }

    // Nothing to report at all.
    if (updates.isEmpty) {
      return const [
        HubUpdate(
          text: "You're all caught up",
          tone: UpdateTone.success,
          target: UpdateTarget.none,
          priority: 99,
        ),
      ];
    }

    updates.sort((a, b) => a.priority.compareTo(b.priority));
    return updates.take(maxShown).toList();
  }
}