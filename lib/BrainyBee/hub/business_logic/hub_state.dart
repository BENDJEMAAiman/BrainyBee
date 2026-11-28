import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/hub/model/hub_stats.dart';
import 'package:mobile_app_project/BrainyBee/hub/model/hub_summary.dart';
import 'package:mobile_app_project/BrainyBee/hub/model/hub_updates.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';

/// Where the hub page is in its life.
enum HubStatus {
  /// Waiting for the habits, the timetable and the homework to arrive.
  loading,

  /// Everything is loaded (any of it may be empty).
  ready,

  /// The data could not be loaded.
  failure,
}

/// Everything the hub page needs to draw itself.
///
/// It holds the raw data of the other features. The numbers the screen shows
/// (summary, updates, statistics) are calculated from it on demand by the pure
/// calculation classes we already have.
class HubState {
  const HubState({
    required this.now,
    this.status = HubStatus.loading,
    this.habits = const [],
    this.timetable = const Timetable(),
    this.homeworks = const [],
  });

  final HubStatus status;
  final List<Habit> habits;
  final Timetable timetable;
  final List<Homework> homeworks;

  /// The current date and time, refreshed at every hour (the evening updates
  /// appear from 18:00, and "late" homework depends on the day).
  final DateTime now;

  HubSummary get summary => HubSummary.from(
    habits: habits,
    timetable: timetable,
    homeworks: homeworks,
    now: now,
  );

  List<HubUpdate> get updates =>
      HubUpdates.build(habits: habits, homeworks: homeworks, now: now);

  HubStats get stats =>
      HubStats.from(habits: habits, homeworks: homeworks, now: now);

  HubState copyWith({
    HubStatus? status,
    List<Habit>? habits,
    Timetable? timetable,
    List<Homework>? homeworks,
    DateTime? now,
  }) {
    return HubState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      timetable: timetable ?? this.timetable,
      homeworks: homeworks ?? this.homeworks,
      now: now ?? this.now,
    );
  }
}