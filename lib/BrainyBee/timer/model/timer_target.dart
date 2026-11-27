/// The homework a timer session is opened for.
///
/// Whoever opens the timer page (later, the router) passes this in when the
/// user taps the timer button of a homework. A quick start from the main page
/// passes no target at all.
class TimerTarget {
  const TimerTarget({
    required this.homeworkId,
    required this.title,
    this.subject = '',
  });

  final String homeworkId;
  final String title;

  /// The homework's subject, or an empty text if it has none.
  final String subject;
}