/// A single habit, for example "Drink 8 cups of water".
///
/// A habit is permanent: it appears every day. We never store a "done" flag
/// that has to be reset. Instead we store the list of dates the user marked
/// as done. A habit is "done" on a given day if that day is in the list.
/// This also gives us the 30-day grid, the streak and the graph for free.
///
/// The 30-day grid is a "window" over those dates. [cycleStart] is the real
/// date behind cell number 1. When the user starts a new round, only
/// [cycleStart] moves; no completed day is ever deleted.
///
/// This class is immutable (its fields never change after creation). To change
/// something we create a modified copy. The Cubit relies on this, because it
/// only updates the screen when it receives a NEW object.
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.createdAt,
    required this.cycleStart,
    this.completedDates = const {},
  });

  /// Rebuilds a habit from the plain data made by [toMap].
  factory Habit.fromMap(Map<String, dynamic> map) {
    final createdAt = DateTime.parse(map['createdAt'] as String);
    final rawCycleStart = map['cycleStart'] as String?;
    final rawDates = map['completedDates'] as List<dynamic>? ?? const [];

    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      iconKey: map['iconKey'] as String? ?? '',
      createdAt: createdAt,
      cycleStart: rawCycleStart == null
          ? createdAt
          : DateTime.parse(rawCycleStart),
      completedDates: rawDates.map((date) => date.toString()).toSet(),
    );
  }

  /// How many cells the habit grid has.
  static const int cycleLength = 30;

  /// Unique id (later this will be the Firestore document id).
  final String id;

  /// Display name, e.g. "Sleep at least 7 hours".
  final String name;

  /// A short key such as "water" or "book". The presentation layer maps it to
  /// an icon. We store a key instead of an icon object so this model stays
  /// free of Flutter code and is easy to save in Firestore.
  final String iconKey;

  /// When the habit was created. It never changes.
  final DateTime createdAt;

  /// The real date behind cell "1" of the CURRENT round. For a brand-new habit
  /// this is the creation day. Pressing the refresh button sets it to today.
  final DateTime cycleStart;

  /// Days marked as done, stored as 'yyyy-MM-dd' text (e.g. '2026-10-26').
  /// Text keys avoid time zone and time-of-day problems that DateTime has.
  final Set<String> completedDates;

  // ---------------------------------------------------------------------------
  // Saving and loading
  // ---------------------------------------------------------------------------

  /// Turns the habit into plain data (text, lists) that any storage can keep.
  /// Dates are written as 'yyyy-MM-dd' text.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconKey': iconKey,
      'createdAt': dateKey(createdAt),
      'cycleStart': dateKey(cycleStart),
      'completedDates': completedDates.toList()..sort(),
    };
  }

  // ---------------------------------------------------------------------------
  // Date helpers
  // ---------------------------------------------------------------------------

  /// Converts a date to its storage key: 2026-10-26 -> '2026-10-26'.
  static String dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Removes the time of day: 2026-10-26 14:35 -> 2026-10-26 00:00.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Number of whole days from [from] to [to] (negative if [to] is earlier).
  /// Uses UTC dates so daylight-saving changes cannot add or remove a day.
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  // ---------------------------------------------------------------------------
  // The 30-day grid ("cycle" / "round")
  // ---------------------------------------------------------------------------

  /// The real date behind grid cell [dayNumber] (1 to 30) in the current
  /// round. This is the ONLY place that decides what a cell number means.
  DateTime dateForCycleDay(int dayNumber) {
    return DateTime(
      cycleStart.year,
      cycleStart.month,
      cycleStart.day + dayNumber - 1,
    );
  }

  /// Which cell [today] is, counting from 1. It can be above 30 once the
  /// round is over.
  int cycleDayNumber(DateTime today) => daysBetween(cycleStart, today) + 1;

  /// True once all 30 days of the round have passed, so the user should start
  /// a new round.
  bool isCycleFinished(DateTime today) => cycleDayNumber(today) > cycleLength;

  /// How many cells of the current round are marked as done.
  int doneCountInCycle() {
    var count = 0;
    for (var number = 1; number <= cycleLength; number++) {
      if (isDoneOn(dateForCycleDay(number))) count++;
    }
    return count;
  }

  // ---------------------------------------------------------------------------
  // Questions the UI can ask
  // ---------------------------------------------------------------------------

  /// Was this habit marked as done on [day]?
  bool isDoneOn(DateTime day) => completedDates.contains(dateKey(day));

  /// Is [day] earlier than the day this habit was created?
  bool isBeforeCreation(DateTime day) =>
      dateOnly(day).isBefore(dateOnly(createdAt));

  /// How many days in a row the habit has been done, counting back from
  /// [today]. It looks at ALL saved days, so starting a new round does not
  /// reset it.
  ///
  /// If today is not done yet we start from yesterday, so the streak does not
  /// drop to 0 in the morning before the user has had a chance to tick it.
  int currentStreak(DateTime today) {
    var day = dateOnly(today);
    if (!isDoneOn(day)) {
      day = DateTime(day.year, day.month, day.day - 1);
    }
    var streak = 0;
    while (isDoneOn(day)) {
      streak++;
      // Building a new DateTime (instead of subtracting a Duration) avoids
      // daylight-saving-time bugs that could skip or repeat a day.
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return streak;
  }

  // ---------------------------------------------------------------------------
  // Changes (each returns a NEW Habit)
  // ---------------------------------------------------------------------------

  /// Returns a copy where [day] is marked done ([done] = true) or not done
  /// ([done] = false). This powers the "Done" and "Undo" buttons.
  Habit withDay(DateTime day, {required bool done}) {
    final updated = Set<String>.of(completedDates);
    if (done) {
      updated.add(dateKey(day));
    } else {
      updated.remove(dateKey(day));
    }
    return copyWith(completedDates: updated);
  }

  /// Returns a copy whose grid starts again from [today] (cell 1 = today).
  /// Completed days are kept.
  Habit startNewCycle(DateTime today) =>
      copyWith(cycleStart: dateOnly(today));

  Habit copyWith({
    String? name,
    String? iconKey,
    DateTime? cycleStart,
    Set<String>? completedDates,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      createdAt: createdAt,
      cycleStart: cycleStart ?? this.cycleStart,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}