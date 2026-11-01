/// Is the user focusing, or taking a break?
enum TimerPhase { focus, rest }

/// What the timer is doing right now.
enum TimerStatus {
  /// Waiting for the user to choose a duration and press Start.
  idle,

  /// Counting down.
  running,

  /// Counting is stopped, and can be resumed.
  paused,

  /// The countdown reached zero.
  finished,
}

/// The fixed choices of the timer page.
class TimerPresets {
  TimerPresets._();

  /// The quick duration buttons, in minutes.
  static const List<int> focusMinutes = [25, 45, 60];

  /// The duration selected when the page opens.
  static const int defaultMinutes = 25;

  /// The length of a break, in minutes.
  static const int breakMinutes = 5;

  /// Limits and step of the custom duration.
  static const int minCustomMinutes = 5;
  static const int maxCustomMinutes = 180;
  static const int customStepMinutes = 5;
}

/// Everything the timer page needs to draw itself at one moment.
///
/// It is immutable: the timer logic never edits it, it creates a new copy.
class TimerSnapshot {
  const TimerSnapshot({
    required this.phase,
    required this.status,
    required this.totalSeconds,
    required this.remainingSeconds,
  });

  /// A timer waiting to start a focus session of [minutes].
  factory TimerSnapshot.idle({int minutes = TimerPresets.defaultMinutes}) {
    return TimerSnapshot(
      phase: TimerPhase.focus,
      status: TimerStatus.idle,
      totalSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
    );
  }

  final TimerPhase phase;
  final TimerStatus status;

  /// The full length of the current session.
  final int totalSeconds;

  /// How much is left of it.
  final int remainingSeconds;

  /// The full length in whole minutes.
  int get totalMinutes => (totalSeconds / 60).round();

  /// How much of the session is left, from 1.0 (all of it) down to 0.0.
  /// The ring on the screen shrinks with this number.
  double get remainingFraction {
    if (totalSeconds <= 0) return 0;
    return (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  /// The time left as text: "24:59", or "1:05:00" when over an hour.
  String get clockText {
    final seconds = remainingSeconds < 0 ? 0 : remainingSeconds;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final mm = minutes.toString().padLeft(2, '0');
    final ss = secs.toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
  }

  TimerSnapshot copyWith({
    TimerPhase? phase,
    TimerStatus? status,
    int? totalSeconds,
    int? remainingSeconds,
  }) {
    return TimerSnapshot(
      phase: phase ?? this.phase,
      status: status ?? this.status,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}