import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_app_project/BrainyBee/timer/business_logic/timer_state.dart';
import 'package:mobile_app_project/BrainyBee/timer/data/timer_repository.dart';
import 'package:mobile_app_project/BrainyBee/timer/model/focus_session_model.dart';
import 'package:mobile_app_project/BrainyBee/timer/model/timer_model.dart';
import 'package:mobile_app_project/BrainyBee/timer/model/timer_target.dart';

/// The brain of the timer page.
///
/// HOW THE COUNTING WORKS: when the timer starts, the Cubit stores the moment
/// it should END ([_endAt]). A small ticker then wakes up four times a second
/// and works out "how much is left" from the clock. It never subtracts one
/// second at a time, so the time stays correct even if the app was in the
/// background (where tickers can be paused): when the app comes back, the
/// next calculation is right again. If the end time has already passed, the
/// session finishes (and is logged) at that moment.
class TimerCubit extends Cubit<TimerState> {
  TimerCubit({
    required TimerRepository repository,
    TimerTarget? target,
    DateTime Function()? now,
  }) : _repository = repository,
       _target = target,
       _clock = now ?? DateTime.now,
       super(TimerState(snapshot: TimerSnapshot.idle()));

  final TimerRepository _repository;

  /// The homework this session is for, if any.
  final TimerTarget? _target;

  /// The clock. It is a parameter so tests (and the preview) can fake time.
  final DateTime Function() _clock;

  Timer? _ticker;

  /// The moment the running countdown reaches zero (null when not running).
  DateTime? _endAt;

  /// The focus length to go back to after a reset or a break.
  int _focusMinutes = TimerPresets.defaultMinutes;

  // ---------------------------------------------------------------------------
  // What the user can do
  // ---------------------------------------------------------------------------

  /// Chooses the focus length. Only possible before a session starts.
  void selectMinutes(int minutes) {
    final snapshot = state.snapshot;
    if (snapshot.status != TimerStatus.idle ||
        snapshot.phase != TimerPhase.focus) {
      return;
    }
    _focusMinutes = minutes;
    emit(state.copyWith(snapshot: TimerSnapshot.idle(minutes: minutes)));
  }

  /// Starts the chosen focus session.
  void start() {
    if (state.snapshot.status != TimerStatus.idle) return;
    _run(state.snapshot);
  }

  /// Stops the countdown but keeps the time that is left.
  void pause() {
    if (state.snapshot.status != TimerStatus.running) return;

    final remaining = _remainingSeconds();
    _stopTicker();
    emit(
      state.copyWith(
        snapshot: state.snapshot.copyWith(
          status: TimerStatus.paused,
          remainingSeconds: remaining,
        ),
      ),
    );
  }

  /// Continues after a pause.
  void resume() {
    if (state.snapshot.status != TimerStatus.paused) return;
    _run(state.snapshot);
  }

  /// Stops everything and goes back to "choose a duration".
  void reset() {
    _stopTicker();
    emit(state.copyWith(snapshot: TimerSnapshot.idle(minutes: _focusMinutes)));
  }

  /// Starts the short break after a finished focus session.
  void startBreak() {
    final snapshot = state.snapshot;
    if (snapshot.status != TimerStatus.finished ||
        snapshot.phase != TimerPhase.focus) {
      return;
    }

    const seconds = TimerPresets.breakMinutes * 60;
    _run(
      const TimerSnapshot(
        phase: TimerPhase.rest,
        status: TimerStatus.idle,
        totalSeconds: seconds,
        remainingSeconds: seconds,
      ),
    );
  }

  /// Remembers that the homework was marked done, so the button is not offered
  /// again. (Marking it done is not this Cubit's job; the page reports it.)
  void homeworkMarkedDone() {
    emit(state.copyWith(homeworkMarkedDone: true));
  }

  /// Recomputes the time left from the clock. The ticker calls this all the
  /// time, and the page calls it when the app returns to the foreground.
  void refresh() {
    if (state.snapshot.status != TimerStatus.running) return;

    final remaining = _remainingSeconds();
    if (remaining <= 0) {
      _finish();
      return;
    }
    if (remaining != state.snapshot.remainingSeconds) {
      emit(
        state.copyWith(
          snapshot: state.snapshot.copyWith(remainingSeconds: remaining),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Inside
  // ---------------------------------------------------------------------------

  /// Starts counting down from the time that is left in [from].
  void _run(TimerSnapshot from) {
    _endAt = _clock().add(Duration(seconds: from.remainingSeconds));
    emit(
      state.copyWith(snapshot: from.copyWith(status: TimerStatus.running)),
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => refresh(),
    );
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _endAt = null;
  }

  /// Seconds left until [_endAt], rounded UP (so a fresh 25:00 timer shows
  /// 25:00 for its first second, and 00:00 is only shown when it is over).
  int _remainingSeconds() {
    final end = _endAt;
    if (end == null) return state.snapshot.remainingSeconds;

    final milliseconds = end.difference(_clock()).inMilliseconds;
    if (milliseconds <= 0) return 0;
    return (milliseconds / 1000).ceil();
  }

  void _finish() {
    _stopTicker();

    final finished = state.snapshot.copyWith(
      status: TimerStatus.finished,
      remainingSeconds: 0,
    );
    emit(state.copyWith(snapshot: finished));

    // Only focus sessions go into the history, not breaks.
    if (finished.phase == TimerPhase.focus) {
      _logSession(finished.totalMinutes);
    }
  }

  Future<void> _logSession(int minutes) async {
    final now = _clock();
    final session = FocusSession(
      id: _repository.generateId(),
      date: DateTime(now.year, now.month, now.day),
      minutes: minutes,
      subject: _target?.subject ?? '',
      homeworkId: _target?.homeworkId ?? '',
    );

    try {
      await _repository.saveSession(session);
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            errorMessage: 'Could not save this session in your history.',
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}