import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_app_project/BrainyBee/habits/business_logic/habit_state.dart';
import 'package:mobile_app_project/BrainyBee/habits/data/habit_repository.dart';
import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';

/// The brain of the Habits page.
///
/// - It listens to the repository and turns every new list into a new state.
/// - The screen calls its methods (toggleDay, addHabit, ...); each one builds
///   the changed habit and hands it to the repository. It never edits the
///   list itself: the repository's stream sends the updated list back, and
///   THAT is what updates the screen.
/// - It also knows what "today" is and moves it forward at midnight.
class HabitCubit extends Cubit<HabitState> {
  HabitCubit({required HabitRepository repository, DateTime Function()? now})
    : _repository = repository,
      _now = now ?? DateTime.now,
      super(HabitState(today: Habit.dateOnly((now ?? DateTime.now)())));

  final HabitRepository _repository;

  /// The clock. It is a parameter so tests can fake the time.
  final DateTime Function() _now;

  StreamSubscription<List<Habit>>? _subscription;
  Timer? _midnightTimer;

  // ---------------------------------------------------------------------------
  // Starting
  // ---------------------------------------------------------------------------

  /// Starts listening to the habits. Also used by the "Try again" button.
  void start() {
    _subscription?.cancel();
    emit(state.copyWith(status: HabitStatus.loading));

    _subscription = _repository.watchHabits().listen(
      (habits) {
        emit(state.copyWith(status: HabitStatus.ready, habits: habits));
      },
      onError: (Object error) {
        emit(state.copyWith(status: HabitStatus.failure));
      },
    );

    refreshToday();
    _scheduleMidnightRefresh();
  }

  // ---------------------------------------------------------------------------
  // Today
  // ---------------------------------------------------------------------------

  /// Moves "today" forward if the date has changed. The page calls this when
  /// the app comes back to the foreground, because the phone may have been
  /// asleep past midnight.
  void refreshToday() {
    final today = Habit.dateOnly(_now());
    if (today != state.today) {
      emit(state.copyWith(today: today));
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = _now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    // One extra second so we are safely past midnight when it fires.
    final wait = nextMidnight.difference(now) + const Duration(seconds: 1);

    _midnightTimer = Timer(wait, () {
      refreshToday();
      _scheduleMidnightRefresh();
    });
  }

  // ---------------------------------------------------------------------------
  // What the user can do
  // ---------------------------------------------------------------------------

  /// Marks [day] as done ([done] = true) or not done for the habit.
  Future<void> toggleDay(String habitId, DateTime day, bool done) async {
    final habit = _find(habitId);
    if (habit == null) return;
    await _save(
      habit.withDay(day, done: done),
      'Could not save your change. Please try again.',
    );
  }

  /// Starts a fresh 30-day round for the habit, beginning today.
  Future<void> startNewCycle(String habitId) async {
    final habit = _find(habitId);
    if (habit == null) return;
    await _save(
      habit.startNewCycle(Habit.dateOnly(_now())),
      'Could not start a new round. Please try again.',
    );
  }

  /// Creates a new habit whose first round starts today.
  Future<void> addHabit(String name, String iconKey) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    final today = Habit.dateOnly(_now());
    final habit = Habit(
      id: _repository.generateId(),
      name: cleanName,
      iconKey: iconKey,
      createdAt: today,
      cycleStart: today,
    );
    await _save(habit, 'Could not add the habit. Please try again.');
  }

  /// Changes the name and icon. The progress is untouched.
  Future<void> editHabit(String habitId, String name, String iconKey) async {
    final cleanName = name.trim();
    final habit = _find(habitId);
    if (habit == null || cleanName.isEmpty) return;
    await _save(
      habit.copyWith(name: cleanName, iconKey: iconKey),
      'Could not save your changes. Please try again.',
    );
  }

  /// Deletes the habit and all of its progress.
  Future<void> deleteHabit(String habitId) async {
    try {
      await _repository.deleteHabit(habitId);
    } catch (_) {
      _reportError('Could not delete the habit. Please try again.');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Habit? _find(String habitId) {
    for (final habit in state.habits) {
      if (habit.id == habitId) return habit;
    }
    return null;
  }

  Future<void> _save(Habit habit, String errorMessage) async {
    try {
      await _repository.saveHabit(habit);
    } catch (_) {
      _reportError(errorMessage);
    }
  }

  void _reportError(String message) {
    if (!isClosed) {
      emit(state.copyWith(errorMessage: message));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _midnightTimer?.cancel();
    return super.close();
  }
}