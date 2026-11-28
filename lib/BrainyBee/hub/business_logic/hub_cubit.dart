import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_app_project/BrainyBee/habits/data/habit_repository.dart';
import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/hub/business_logic/hub_state.dart';
import 'package:mobile_app_project/BrainyBee/studies/data/studies_respository.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';

/// The brain of the hub page.
///
/// The hub only READS: it listens to the habits and to the timetable and the
/// homework, and turns every change into a new state. Because all pages share
/// the same storage, something done on the Habits or Studies page shows up here
/// right away.
class HubCubit extends Cubit<HubState> {
  HubCubit({
    required HabitRepository habitRepository,
    required StudiesRepository studiesRepository,
    DateTime Function()? now,
  }) : _habitRepository = habitRepository,
       _studiesRepository = studiesRepository,
       _clock = now ?? DateTime.now,
       super(HubState(now: (now ?? DateTime.now)()));

  final HabitRepository _habitRepository;
  final StudiesRepository _studiesRepository;

  /// The clock. It is a parameter so tests can fake the time.
  final DateTime Function() _clock;

  StreamSubscription<List<Habit>>? _habitsSubscription;
  StreamSubscription<Timetable>? _timetableSubscription;
  StreamSubscription<List<Homework>>? _homeworksSubscription;
  Timer? _hourTimer;

  bool _habitsLoaded = false;
  bool _timetableLoaded = false;
  bool _homeworksLoaded = false;

  /// Starts listening to the data. Also used by the "Try again" button.
  void start() {
    _habitsSubscription?.cancel();
    _timetableSubscription?.cancel();
    _homeworksSubscription?.cancel();
    _habitsLoaded = false;
    _timetableLoaded = false;
    _homeworksLoaded = false;

    emit(state.copyWith(status: HubStatus.loading));

    _habitsSubscription = _habitRepository.watchHabits().listen((habits) {
      _habitsLoaded = true;
      _emitData(habits: habits);
    }, onError: _onLoadError);

    _timetableSubscription = _studiesRepository.watchTimetable().listen((
      timetable,
    ) {
      _timetableLoaded = true;
      _emitData(timetable: timetable);
    }, onError: _onLoadError);

    _homeworksSubscription = _studiesRepository.watchHomeworks().listen((
      homeworks,
    ) {
      _homeworksLoaded = true;
      _emitData(homeworks: homeworks);
    }, onError: _onLoadError);

    refreshNow();
    _scheduleHourRefresh();
  }

  /// Emits new data. The page counts as "ready" only once ALL three sources
  /// have arrived at least once.
  void _emitData({
    List<Habit>? habits,
    Timetable? timetable,
    List<Homework>? homeworks,
  }) {
    final allLoaded = _habitsLoaded && _timetableLoaded && _homeworksLoaded;
    emit(
      state.copyWith(
        status: allLoaded ? HubStatus.ready : HubStatus.loading,
        habits: habits,
        timetable: timetable,
        homeworks: homeworks,
      ),
    );
  }

  void _onLoadError(Object error) {
    emit(state.copyWith(status: HubStatus.failure));
  }

  /// Updates "now" if the hour (or the day) has changed. The page calls this
  /// when the app comes back to the foreground.
  void refreshNow() {
    final now = _clock();
    final old = state.now;
    final sameHour =
        now.year == old.year &&
        now.month == old.month &&
        now.day == old.day &&
        now.hour == old.hour;
    if (!sameHour) {
      emit(state.copyWith(now: now));
    }
  }

  void _scheduleHourRefresh() {
    _hourTimer?.cancel();
    final now = _clock();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    // One extra second so we are safely past the hour when it fires.
    final wait = nextHour.difference(now) + const Duration(seconds: 1);

    _hourTimer = Timer(wait, () {
      refreshNow();
      _scheduleHourRefresh();
    });
  }

  @override
  Future<void> close() async {
    await _habitsSubscription?.cancel();
    await _timetableSubscription?.cancel();
    await _homeworksSubscription?.cancel();
    _hourTimer?.cancel();
    return super.close();
  }
}