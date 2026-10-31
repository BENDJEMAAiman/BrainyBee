/// Where a homework item stands on a given day. Nothing is stored for this: it
/// is worked out from the dates every time (no midnight job needed).
enum HomeworkStatus {
  /// Not done, and not late yet.
  todo,

  /// Not done, and the due date is before today.
  missed,

  /// Done today. It stays visible for the rest of the day.
  doneToday,

  /// Done on an earlier day. It is hidden from the lists but kept in the data.
  archived,
}

/// One homework item, e.g. "Exercises 4 to 7" for Math, due Thursday.
///
/// Like Habit, this class is immutable: every change returns a NEW Homework.
/// All dates are stored as plain days (no time of day).
class Homework {
  const Homework({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.createdAt,
    this.completedOn,
  });

  /// Rebuilds a homework item from the plain data made by [toMap].
  factory Homework.fromMap(Map<String, dynamic> map) {
    final rawCompletedOn = map['completedOn'] as String?;
    return Homework(
      id: map['id'] as String,
      title: map['title'] as String,
      subject: map['subject'] as String? ?? '',
      dueDate: DateTime.parse(map['dueDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedOn: rawCompletedOn == null
          ? null
          : DateTime.parse(rawCompletedOn),
    );
  }

  final String id;
  final String title;

  /// The subject's name, or an empty text if none was chosen.
  final String subject;

  /// The day the homework is due.
  final DateTime dueDate;

  /// The day the homework was added.
  final DateTime createdAt;

  /// The day the homework was marked done, or null if it is not done.
  final DateTime? completedOn;

  // ---------------------------------------------------------------------------
  // Date helpers (same idea as in Habit)
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
  // Questions the UI can ask
  // ---------------------------------------------------------------------------

  bool get isCompleted => completedOn != null;

  /// Which list this homework belongs to on [today].
  HomeworkStatus statusOn(DateTime today) {
    final day = dateOnly(today);

    final completed = completedOn;
    if (completed != null) {
      return dateOnly(completed).isBefore(day)
          ? HomeworkStatus.archived
          : HomeworkStatus.doneToday;
    }

    return dateOnly(dueDate).isBefore(day)
        ? HomeworkStatus.missed
        : HomeworkStatus.todo;
  }

  /// Days from [today] until the due date (0 = today, 1 = tomorrow).
  int daysUntilDue(DateTime today) => daysBetween(today, dueDate);

  /// How many days past the due date it is (0 if it is not late).
  int daysLate(DateTime today) {
    final days = daysBetween(dueDate, today);
    return days < 0 ? 0 : days;
  }

  // ---------------------------------------------------------------------------
  // Changes (each returns a NEW Homework)
  // ---------------------------------------------------------------------------

  /// Marks the homework done on [today] ([done] = true) or not done.
  Homework withCompleted({required bool done, required DateTime today}) {
    return Homework(
      id: id,
      title: title,
      subject: subject,
      dueDate: dueDate,
      createdAt: createdAt,
      completedOn: done ? dateOnly(today) : null,
    );
  }

  /// Changes the title, subject or due date. Completion is kept.
  Homework copyWith({String? title, String? subject, DateTime? dueDate}) {
    return Homework(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      completedOn: completedOn,
    );
  }

  // ---------------------------------------------------------------------------
  // Saving
  // ---------------------------------------------------------------------------

  /// Turns the homework into plain data that any storage can keep.
  Map<String, dynamic> toMap() {
    final completed = completedOn;
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'dueDate': dateKey(dueDate),
      'createdAt': dateKey(createdAt),
      'completedOn': completed == null ? null : dateKey(completed),
    };
  }
}

/// Splits a list of homework into the three groups the screen shows, each
/// already sorted. Pure calculation, no Flutter code.
class HomeworkGroups {
  const HomeworkGroups({
    required this.todo,
    required this.missed,
    required this.doneToday,
  });

  factory HomeworkGroups.from(List<Homework> all, DateTime today) {
    final todoList = <Homework>[];
    final missedList = <Homework>[];
    final doneList = <Homework>[];

    for (final homework in all) {
      switch (homework.statusOn(today)) {
        case HomeworkStatus.todo:
          todoList.add(homework);
        case HomeworkStatus.missed:
          missedList.add(homework);
        case HomeworkStatus.doneToday:
          doneList.add(homework);
        case HomeworkStatus.archived:
          break; // Hidden from the lists.
      }
    }

    int byDueThenTitle(Homework a, Homework b) {
      final byDate = a.dueDate.compareTo(b.dueDate);
      if (byDate != 0) return byDate;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }

    todoList.sort(byDueThenTitle);
    missedList.sort(byDueThenTitle); // oldest first
    doneList.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );

    return HomeworkGroups(
      todo: todoList,
      missed: missedList,
      doneToday: doneList,
    );
  }

  /// Not done and not late, soonest due date first.
  final List<Homework> todo;

  /// Not done and late, oldest due date first.
  final List<Homework> missed;

  /// Marked done today.
  final List<Homework> doneToday;

  bool get isEmpty => todo.isEmpty && missed.isEmpty && doneToday.isEmpty;
}