import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/studies_screen.dart';

/// TEMPORARY file: delete it when the Cubit is connected.
/// Run it with:  flutter run -t lib/studies_preview.dart -d chrome --web-port 5000
void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _PreviewPage(),
    );
  }
}

class _PreviewPage extends StatefulWidget {
  const _PreviewPage();

  @override
  State<_PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<_PreviewPage> {
  // A few made-up timetable cells (day, slot) -> subject.
  Timetable _timetable = Timetable(
    cells: {
      Timetable.cellKey(0, 0): 'Math',
      Timetable.cellKey(0, 1): 'Math',
      Timetable.cellKey(0, 2): 'Physics',
      Timetable.cellKey(0, 4): 'English',
      Timetable.cellKey(1, 0): 'Arabic',
      Timetable.cellKey(1, 1): 'Chemistry',
      Timetable.cellKey(1, 5): 'Sport',
      Timetable.cellKey(2, 2): 'Math',
      Timetable.cellKey(2, 3): 'History',
      Timetable.cellKey(3, 0): 'Physics',
      Timetable.cellKey(3, 4): 'English',
      Timetable.cellKey(4, 1): 'Biology',
      Timetable.cellKey(4, 2): 'Biology',
    },
  );

  late List<Homework> _homeworks;

  DateTime get _today => Homework.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _homeworks = _buildDemoHomeworks();
  }

  List<Homework> _buildDemoHomeworks() {
    final today = _today;
    DateTime inDays(int n) => DateTime(today.year, today.month, today.day + n);

    return [
      // To do
      Homework(
        id: '1',
        title: 'Exercises 4 to 7, page 52',
        subject: 'Math',
        dueDate: inDays(0),
        createdAt: inDays(-2),
      ),
      Homework(
        id: '2',
        title: 'Read chapter 3',
        subject: 'English',
        dueDate: inDays(1),
        createdAt: inDays(-1),
      ),
      Homework(
        id: '3',
        title: 'Physics lab report',
        subject: 'Physics',
        dueDate: inDays(4),
        createdAt: inDays(-3),
      ),
      // Missed
      Homework(
        id: '4',
        title: 'Chemistry worksheet',
        subject: 'Chemistry',
        dueDate: inDays(-2),
        createdAt: inDays(-6),
      ),
      // Done today
      Homework(
        id: '5',
        title: 'Vocabulary list',
        subject: 'English',
        dueDate: inDays(0),
        createdAt: inDays(-4),
        completedOn: inDays(0),
      ),
      // Done on an earlier day: hidden from the lists on purpose.
      Homework(
        id: '6',
        title: 'Old finished task (you should not see this)',
        subject: 'Math',
        dueDate: inDays(-3),
        createdAt: inDays(-8),
        completedOn: inDays(-1),
      ),
    ];
  }

  void _replace(Homework updated) {
    setState(() {
      _homeworks = [
        for (final homework in _homeworks)
          homework.id == updated.id ? updated : homework,
      ];
    });
  }

  void _toggle(Homework homework) {
    final isDone = homework.statusOn(_today) == HomeworkStatus.doneToday;
    _replace(homework.withCompleted(done: !isDone, today: _today));
  }

  @override
  Widget build(BuildContext context) {
    return StudiesScreen(
      timetable: _timetable,
      homeworks: _homeworks,
      // To test the highlight on any day, replace DateTime.now() with e.g.
      // DateTime(2026, 11, 1, 9, 30)  (a Sunday, 9:30).
      now: DateTime.now(),
      onTimetableCellChanged: (day, slot, subject) {
        setState(() {
          _timetable = _timetable.withCell(day, slot, subject);
        });
      },
      onAddHomework: (data) {
        setState(() {
          _homeworks = [
            ..._homeworks,
            Homework(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              title: data.title,
              subject: data.subject,
              dueDate: data.dueDate,
              createdAt: _today,
            ),
          ];
        });
      },
      onEditHomework: (homework, data) {
        _replace(
          homework.copyWith(
            title: data.title,
            subject: data.subject,
            dueDate: data.dueDate,
          ),
        );
      },
      onDeleteHomework: (homework) {
        setState(() {
          _homeworks = _homeworks.where((h) => h.id != homework.id).toList();
        });
      },
      onToggleHomework: _toggle,
      onStartTimer: (homework) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('The timer for "${homework.title}" opens here.'),
            ),
          );
      },
    );
  }
}