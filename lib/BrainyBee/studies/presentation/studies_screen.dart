import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/homework_form_sheet.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/homework_list.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/timetable_cell_sheet.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/timetable_table.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The Studies page: the weekly timetable, and under it the homework list.
///
/// This screen owns NO data. It draws the [timetable] and [homeworks] it
/// receives and reports what the user did through the callbacks. For now a
/// preview file supplies dummy data; later a Cubit will supply the real data
/// and handle the callbacks.
class StudiesScreen extends StatelessWidget {
  const StudiesScreen({
    super.key,
    required this.timetable,
    required this.homeworks,
    required this.now,
    required this.onTimetableCellChanged,
    required this.onAddHomework,
    required this.onEditHomework,
    required this.onDeleteHomework,
    required this.onToggleHomework,
    required this.onStartTimer,
  });

  final Timetable timetable;
  final List<Homework> homeworks;

  /// The current date and time. It is used to highlight today's column and the
  /// current session in the timetable, and to decide which homework is late.
  final DateTime now;

  /// The user saved a timetable cell. [subject] is empty if they cleared it.
  final void Function(int day, int slot, String subject) onTimetableCellChanged;

  /// The user filled in the "new homework" form.
  final void Function(HomeworkFormData data) onAddHomework;

  /// The user saved changes to [homework] in the edit form.
  final void Function(Homework homework, HomeworkFormData data) onEditHomework;

  /// The user confirmed deleting [homework].
  final void Function(Homework homework) onDeleteHomework;

  /// The user tapped the done circle of [homework].
  final void Function(Homework homework) onToggleHomework;

  /// The user tapped the timer button of [homework].
  final void Function(Homework homework) onStartTimer;

  Future<void> _editCell(BuildContext context, int day, int slot) async {
    final result = await showTimetableCellSheet(
      context,
      title:
          '${TimetableLayout.dayNames[day]} · ${TimetableLayout.slotLabel(slot)}',
      initial: timetable.subjectAt(day, slot),
      suggestions: timetable.subjects,
    );

    // null means the sheet was closed without saving.
    if (result != null) {
      onTimetableCellChanged(day, slot, result);
    }
  }

  Future<void> _openHomeworkForm(
    BuildContext context, {
    Homework? existing,
  }) async {
    final result = await showHomeworkFormSheet(
      context,
      today: Homework.dateOnly(now),
      subjects: timetable.subjects,
      initial: existing == null
          ? null
          : HomeworkFormData(
              title: existing.title,
              subject: existing.subject,
              dueDate: existing.dueDate,
            ),
    );

    if (result == null) return;

    if (result.isDelete) {
      if (existing != null) onDeleteHomework(existing);
      return;
    }

    final data = result.data;
    if (data == null) return;

    if (existing == null) {
      onAddHomework(data);
    } else {
      onEditHomework(existing, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Studies',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          // Keeps the layout tidy on wide screens (e.g. Chrome).
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              TimetableTable(
                timetable: timetable,
                now: now,
                onCellTap: (day, slot) => _editCell(context, day, slot),
              ),
              const SizedBox(height: 16),
              HomeworkList(
                homeworks: homeworks,
                today: Homework.dateOnly(now),
                onAdd: () => _openHomeworkForm(context),
                onToggleDone: onToggleHomework,
                onEdit: (homework) =>
                    _openHomeworkForm(context, existing: homework),
                onStartTimer: onStartTimer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}