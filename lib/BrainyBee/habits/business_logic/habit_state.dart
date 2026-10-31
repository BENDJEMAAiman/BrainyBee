import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';

/// Where the Habits page is in its life.
enum HabitStatus {
  /// Waiting for the first list of habits.
  loading,

  /// Habits are loaded (the list may be empty).
  ready,

  /// The habits could not be loaded.
  failure,
}

/// Everything the Habits page needs to draw itself.
///
/// It is immutable: the Cubit never edits it, it emits a new copy.
class HabitState {
  const HabitState({
    required this.today,
    this.status = HabitStatus.loading,
    this.habits = const [],
    this.errorMessage,
  });

  final HabitStatus status;
  final List<Habit> habits;

  /// The current date (without time). The Cubit updates it at midnight so the
  /// grids and streaks move to the new day.
  final DateTime today;

  /// A short message to show once (for example in a SnackBar) when saving
  /// failed. It is null in every normal state.
  final String? errorMessage;

  /// Returns a copy with some fields changed.
  /// NOTE: [errorMessage] is cleared unless you pass it again, so an error is
  /// only ever present in the one state that reports it.
  HabitState copyWith({
    HabitStatus? status,
    List<Habit>? habits,
    DateTime? today,
    String? errorMessage,
  }) {
    return HabitState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      today: today ?? this.today,
      errorMessage: errorMessage,
    );
  }
}