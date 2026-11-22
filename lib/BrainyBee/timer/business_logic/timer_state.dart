import 'package:mobile_app_project/BrainyBee/timer/model/timer_model.dart';

/// Everything the timer page needs to draw itself.
///
/// It is immutable: the Cubit never edits it, it emits a new copy.
class TimerState {
  const TimerState({
    required this.snapshot,
    this.homeworkMarkedDone = false,
    this.errorMessage,
  });

  /// The countdown: phase, status and the time left.
  final TimerSnapshot snapshot;

  /// True once the user used "Mark homework as done", so the button is not
  /// offered again.
  final bool homeworkMarkedDone;

  /// A short message to show once (for example in a SnackBar) when saving
  /// failed. It is null in every normal state.
  final String? errorMessage;

  /// Returns a copy with some fields changed.
  /// NOTE: [errorMessage] is cleared unless you pass it again, so an error is
  /// only ever present in the one state that reports it.
  TimerState copyWith({
    TimerSnapshot? snapshot,
    bool? homeworkMarkedDone,
    String? errorMessage,
  }) {
    return TimerState(
      snapshot: snapshot ?? this.snapshot,
      homeworkMarkedDone: homeworkMarkedDone ?? this.homeworkMarkedDone,
      errorMessage: errorMessage,
    );
  }
}