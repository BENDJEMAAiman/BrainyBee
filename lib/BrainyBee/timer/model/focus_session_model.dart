/// One finished focus session, saved in the history.
///
/// Only completed focus sessions are saved (not breaks, and not sessions the
/// user stopped early). This history will feed "time studied" statistics later.
class FocusSession {
  const FocusSession({
    required this.id,
    required this.date,
    required this.minutes,
    required this.subject,
    this.homeworkId = '',
  });

  /// Rebuilds a session from the plain data made by [toMap].
  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      minutes: (map['minutes'] as num).toInt(),
      subject: map['subject'] as String? ?? '',
      homeworkId: map['homeworkId'] as String? ?? '',
    );
  }

  final String id;

  /// The day the session ended (no time of day).
  final DateTime date;

  /// How long the session was, in minutes.
  final int minutes;

  /// The subject of the homework it was for, or an empty text.
  final String subject;

  /// The id of the homework it was for, or an empty text.
  final String homeworkId;

  /// Converts a date to its storage key: 2026-10-26 -> '2026-10-26'.
  static String dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Turns the session into plain data that any storage can keep.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': dateKey(date),
      'minutes': minutes,
      'subject': subject,
      'homeworkId': homeworkId,
    };
  }
}