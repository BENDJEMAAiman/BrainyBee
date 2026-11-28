import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_app_project/BrainyBee/studies/business_logic/studies_state.dart';
import 'package:mobile_app_project/BrainyBee/studies/data/studies_respository.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';

/// The brain of the Studies page.
///
/// - It listens to the repository (timetable and homework) and turns every
///   change into a new state.
/// - The screen calls its methods; each one builds the changed object and hands
///   it to the repository. It never edits the lists itself: the repository's
///   stream sends the updated data back, and THAT is what updates the screen.
/// - It also knows what time it is and refreshes it at every hour.
class StudiesCubit extends Cubit<StudiesState> {
  StudiesCubit({required StudiesRepository repository, DateTime Function()? now})
    : _repository = repository,
      _clock = now ?? DateTime.now,
      super(StudiesState(now: (now ?? DateTime.now)()));

  final StudiesRepository _repository;

  /// The clock. It is a parameter so tests can fake the time.
  final DateTime Function() _clock;

  StreamSubscription<Timetable>? _timetableSubscription;
  StreamSubscription<List<Homework>>? _homeworksSubscription;
  Timer? _hourTimer;

  bool _timetableLoaded = false;
  bool _homeworksLoaded = false;

  // ---------------------------------------------------------------------------
  // Starting
  // ---------------------------------------------------------------------------

  /// Starts listening to the data. Also used by the "Try again" button.
  void start() {
    _timetableSubscription?.cancel();
    _homeworksSubscription?.cancel();
    _timetableLoaded = false;
    _homeworksLoaded = false;

    emit(state.copyWith(status: StudiesStatus.loading));

    _timetableSubscription = _repository.watchTimetable().listen((timetable) {
      _timetableLoaded = true;
      _emitData(timetable: timetable);
    }, onError: _onLoadError);

    _homeworksSubscription = _repository.watchHomeworks().listen((homeworks) {
      _homeworksLoaded = true;
      _emitData(homeworks: homeworks);
    }, onError: _onLoadError);

    refreshNow();
    _scheduleHourRefresh();
  }

  /// Emits new data. The page counts as "ready" only once BOTH the timetable
  /// and the homework have arrived at least once.
  void _emitData({Timetable? timetable, List<Homework>? homeworks}) {
    emit(
      state.copyWith(
        status: (_timetableLoaded && _homeworksLoaded)
            ? StudiesStatus.ready
            : StudiesStatus.loading,
        timetable: timetable,
        homeworks: homeworks,
      ),
    );
  }

  void _onLoadError(Object error) {
    emit(state.copyWith(status: StudiesStatus.failure));
  }

  // ---------------------------------------------------------------------------
  // Time
  // ---------------------------------------------------------------------------

  /// Updates "now" if the hour (or the day) has changed. The page calls this
  /// when the app comes back to the foreground, because the phone may have been
  /// asleep for a while.
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

  // ---------------------------------------------------------------------------
  // Timetable
  // ---------------------------------------------------------------------------

  /// Writes [subject] in the cell at [day] (0-4) and [slot] (0-6). An empty
  /// [subject] clears the cell.
  Future<void> setTimetableCell(int day, int slot, String subject) async {
    final updated = state.timetable.withCell(day, slot, subject);
    try {
      await _repository.saveTimetable(updated);
    } catch (_) {
      _reportError('Could not save your timetable. Please try again.');
    }
  }

  // ---------------------------------------------------------------------------
  // Homework
  // ---------------------------------------------------------------------------

  /// Adds a new homework.
  Future<void> addHomework({
    required String title,
    required String subject,
    required DateTime dueDate,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;

    final homework = Homework(
      id: _repository.generateId(),
      title: cleanTitle,
      subject: subject,
      dueDate: Homework.dateOnly(dueDate),
      createdAt: Homework.dateOnly(_clock()),
    );
    await _saveHomework(
      homework,
      'Could not add the homework. Please try again.',
    );
  }

  /// Changes the title, subject and due date. Completion is kept.
  Future<void> editHomework(
    String homeworkId, {
    required String title,
    required String subject,
    required DateTime dueDate,
  }) async {
    final cleanTitle = title.trim();
    final homework = _find(homeworkId);
    if (homework == null || cleanTitle.isEmpty) return;

    await _saveHomework(
      homework.copyWith(
        title: cleanTitle,
        subject: subject,
        dueDate: Homework.dateOnly(dueDate),
      ),
      'Could not save your changes. Please try again.',
    );
  }

  /// Ticks or unticks a homework.
  ///
  /// Done today becomes not done again. Anything else (including a late
  /// homework) becomes done today.
  Future<void> toggleHomework(String homeworkId) async {
    final homework = _find(homeworkId);
    if (homework == null) return;

    final today = Homework.dateOnly(_clock());
    final isDoneToday = homework.statusOn(today) == HomeworkStatus.doneToday;

    await _saveHomework(
      homework.withCompleted(done: !isDoneToday, today: today),
      'Could not save your change. Please try again.',
    );
  }

  /// Deletes a homework.
  Future<void> deleteHomework(String homeworkId) async {
    try {
      await _repository.deleteHomework(homeworkId);
    } catch (_) {
      _reportError('Could not delete the homework. Please try again.');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Homework? _find(String homeworkId) {
    for (final homework in state.homeworks) {
      if (homework.id == homeworkId) return homework;
    }
    return null;
  }

  Future<void> _saveHomework(Homework homework, String errorMessage) async {
    try {
      await _repository.saveHomework(homework);
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
    await _timetableSubscription?.cancel();
    await _homeworksSubscription?.cancel();
    _hourTimer?.cancel();
    return super.close();
  }
}