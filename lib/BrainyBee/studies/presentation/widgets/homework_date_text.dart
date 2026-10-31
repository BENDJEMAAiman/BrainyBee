import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';

/// Turns dates into the short texts shown in the homework UI.
class HomeworkDateText {
  HomeworkDateText._();

  // DateTime.weekday: Monday = 1 ... Sunday = 7. With `% 7` Sunday becomes 0.
  static const List<String> _weekdayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// A date as text: "Mon, 2 Nov".
  static String short(DateTime date) {
    final weekday = _weekdayNames[date.weekday % 7].substring(0, 3);
    return '$weekday, ${date.day} ${_monthNames[date.month - 1]}';
  }

  /// The line shown under a homework title, e.g. "Due tomorrow" or
  /// "2 days late".
  static String dueLabel(Homework homework, DateTime today) {
    switch (homework.statusOn(today)) {
      case HomeworkStatus.missed:
        final days = homework.daysLate(today);
        return days == 1 ? '1 day late' : '$days days late';

      case HomeworkStatus.doneToday:
      case HomeworkStatus.archived:
        return 'Done';

      case HomeworkStatus.todo:
        final days = homework.daysUntilDue(today);
        if (days == 0) return 'Due today';
        if (days == 1) return 'Due tomorrow';
        if (days < 7) {
          return 'Due ${_weekdayNames[homework.dueDate.weekday % 7]}';
        }
        final due = homework.dueDate;
        return 'Due ${due.day} ${_monthNames[due.month - 1]}';
    }
  }
}