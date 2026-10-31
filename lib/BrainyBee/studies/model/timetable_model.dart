/// The fixed shape of the school week. The table never changes shape; only
/// the text inside its cells does.
///
/// To change the school days or hours, edit the lists below. Nothing else in
/// the app needs to change.
class TimetableLayout {
  TimetableLayout._();

  /// The school days, in the order they appear (left to right).
  static const List<String> dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];

  /// Short names shown in the table header.
  static const List<String> dayShortNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];

  static const List<int> slotStartHours = [8, 9, 10, 11, 13, 14, 15];

  /// The break row is drawn after this session (index 3 = the 11-12 session).
  static const int breakAfterSlot = 3;

  static int get dayCount => dayNames.length;
  static int get slotCount => slotStartHours.length;

  /// A session as text, e.g. "8–9" or "13–14".
  static String slotLabel(int slot) {
    final start = slotStartHours[slot];
    return '$start–${start + 1}';
  }

  /// The break as text: from the end of the session before it to the start of
  /// the session after it (here "12–13").
  static String get breakLabel {
    final end = slotStartHours[breakAfterSlot] + 1;
    final start = slotStartHours[breakAfterSlot + 1];
    return '$end–$start';
  }

  /// Which column [date] falls in (0 = Sunday ... 4 = Thursday), or null if it
  /// is a day without school (Friday, Saturday).
  ///
  /// DateTime.weekday is Monday = 1 ... Sunday = 7, so `% 7` makes Sunday 0.
  static int? dayIndexFor(DateTime date) {
    final index = date.weekday % 7;
    return index < dayCount ? index : null;
  }

  /// Which row [time] falls in, or null if it is outside school hours
  /// (before 8, the 12-13 break, or after 16).
  static int? slotIndexFor(DateTime time) {
    final index = slotStartHours.indexOf(time.hour);
    return index == -1 ? null : index;
  }
}

/// What the user wrote in the timetable: one short text per filled cell.
///
/// Empty cells are simply not stored. Like Habit, this class is immutable;
/// every change returns a NEW Timetable.
class Timetable {
  const Timetable({this.cells = const {}});

  /// Rebuilds a timetable from the plain data made by [toMap].
  factory Timetable.fromMap(Map<String, dynamic> map) {
    final raw = map['cells'] as Map<dynamic, dynamic>? ?? const {};
    return Timetable(
      cells: {
        for (final entry in raw.entries)
          entry.key.toString(): entry.value.toString(),
      },
    );
  }

  /// Key of the cell at [day] (0-4) and [slot] (0-6), e.g. "d1s2".
  static String cellKey(int day, int slot) => 'd${day}s$slot';

  /// cell key -> subject text.
  final Map<String, String> cells;

  /// The text in a cell, or an empty text if the cell is empty.
  String subjectAt(int day, int slot) => cells[cellKey(day, slot)] ?? '';

  /// Returns a copy where the cell contains [subject]. An empty [subject]
  /// clears the cell.
  Timetable withCell(int day, int slot, String subject) {
    final updated = Map<String, String>.of(cells);
    final clean = subject.trim();
    if (clean.isEmpty) {
      updated.remove(cellKey(day, slot));
    } else {
      updated[cellKey(day, slot)] = clean;
    }
    return Timetable(cells: updated);
  }

  /// Every different subject written in the table, sorted A to Z (ignoring
  /// capital letters). The cell editor shows these as quick choices, and the
  /// homework form will use them too.
  List<String> get subjects {
    final seen = <String>{};
    final result = <String>[];
    for (final subject in cells.values) {
      if (seen.add(subject.toLowerCase())) {
        result.add(subject);
      }
    }
    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  /// Turns the timetable into plain data that any storage can keep.
  Map<String, dynamic> toMap() => {'cells': cells};
}