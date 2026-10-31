import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/homework_form_sheet.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/homework_list.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// TEMPORARY file: delete it when the Studies screen exists.
/// Run it with:  flutter run -t lib/homework_preview.dart -d chrome --web-port 5000
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
  // In the real screen these come from the timetable.
  static const List<String> _subjects = [
    'Arabic',
    'Chemistry',
    'English',
    'History',
    'Math',
    'Physics',
  ];

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
      Homework(
        id: '4',
        title: 'Essay draft',
        subject: 'Arabic',
        dueDate: inDays(12),
        createdAt: inDays(-1),
      ),
      // Missed
      Homework(
        id: '5',
        title: 'Chemistry worksheet',
        subject: 'Chemistry',
        dueDate: inDays(-2),
        createdAt: inDays(-6),
      ),
      Homework(
        id: '6',
        title: 'History summary',
        subject: '',
        dueDate: inDays(-1),
        createdAt: inDays(-5),
      ),
      // Done today
      Homework(
        id: '7',
        title: 'Vocabulary list',
        subject: 'English',
        dueDate: inDays(0),
        createdAt: inDays(-4),
        completedOn: inDays(0),
      ),
      // Done on an earlier day: hidden from the lists on purpose.
      Homework(
        id: '8',
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

  void _toggleDone(Homework homework) {
    final isDone = homework.statusOn(_today) == HomeworkStatus.doneToday;
    _replace(homework.withCompleted(done: !isDone, today: _today));
  }

  Future<void> _openForm({Homework? existing}) async {
    final result = await showHomeworkFormSheet(
      context,
      today: _today,
      subjects: _subjects,
      initial: existing == null
          ? null
          : HomeworkFormData(
              title: existing.title,
              subject: existing.subject,
              dueDate: existing.dueDate,
            ),
    );

    if (result == null || !mounted) return;

    if (result.isDelete && existing != null) {
      setState(() {
        _homeworks = _homeworks.where((h) => h.id != existing.id).toList();
      });
      return;
    }

    final data = result.data;
    if (data == null) return;

    if (existing == null) {
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
    } else {
      _replace(
        existing.copyWith(
          title: data.title,
          subject: data.subject,
          dueDate: data.dueDate,
        ),
      );
    }
  }

  void _startTimer(Homework homework) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('The timer for "${homework.title}" opens here.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                HomeworkList(
                  homeworks: _homeworks,
                  today: _today,
                  onAdd: () => _openForm(),
                  onToggleDone: _toggleDone,
                  onEdit: (homework) => _openForm(existing: homework),
                  onStartTimer: _startTimer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}