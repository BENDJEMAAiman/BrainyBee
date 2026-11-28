import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';

/// Where the Studies page is in its life.
enum StudiesStatus {
  /// Waiting for the timetable and the homework to arrive.
  loading,

  /// Both are loaded (they may be empty).
  ready,

  /// The data could not be loaded.
  failure,
}

/// Everything the Studies page needs to draw itself.
///
/// It is immutable: the Cubit never edits it, it emits a new copy.
class StudiesState {
  const StudiesState({
    required this.now,
    this.status = StudiesStatus.loading,
    this.timetable = const Timetable(),
    this.homeworks = const [],
    this.errorMessage,
  });

  final StudiesStatus status;
  final Timetable timetable;
  final List<Homework> homeworks;

  /// The current date and time, refreshed at every hour. The timetable uses it
  /// to highlight today's column and the current session, and the homework
  /// uses it to know what is late.
  final DateTime now;

  /// A short message to show once (for example in a SnackBar) when saving
  /// failed. It is null in every normal state.
  final String? errorMessage;

  /// Returns a copy with some fields changed.
  /// NOTE: [errorMessage] is cleared unless you pass it again, so an error is
  /// only ever present in the one state that reports it.
  StudiesState copyWith({
    StudiesStatus? status,
    Timetable? timetable,
    List<Homework>? homeworks,
    DateTime? now,
    String? errorMessage,
  }) {
    return StudiesState(
      status: status ?? this.status,
      timetable: timetable ?? this.timetable,
      homeworks: homeworks ?? this.homeworks,
      now: now ?? this.now,
      errorMessage: errorMessage,
    );
  }
}