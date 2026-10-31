import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/timetable_cell_sheet.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/timetable_table.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// TEMPORARY file: delete it when the Studies screen exists.
/// Run it with:  flutter run -t lib/timetable_preview.dart -d chrome --web-port 5000
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
  // A few made-up cells so the table is not empty (day, slot) -> subject.
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

  Future<void> _editCell(int day, int slot) async {
    final result = await showTimetableCellSheet(
      context,
      title:
          '${TimetableLayout.dayNames[day]} · ${TimetableLayout.slotLabel(slot)}',
      initial: _timetable.subjectAt(day, slot),
      suggestions: _timetable.subjects,
    );

    // null means the sheet was closed without saving.
    if (result == null || !mounted) return;
    setState(() {
      _timetable = _timetable.withCell(day, slot, result);
    });
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
                TimetableTable(
                  timetable: _timetable,
                  // To test the highlight on any day, replace DateTime.now()
                  // with e.g. DateTime(2026, 11, 1, 9, 30)  (a Sunday, 9:30).
                  now: DateTime.now(),
                  onCellTap: _editCell,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}