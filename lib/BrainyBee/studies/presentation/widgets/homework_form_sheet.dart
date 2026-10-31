import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/homework_date_text.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/subject_color.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

// Neutral background of an unselected chip.
const Color _chipBackground = Color(0xFFF6F1E7);

/// What the user typed and picked in the homework form.
class HomeworkFormData {
  const HomeworkFormData({
    required this.title,
    required this.subject,
    required this.dueDate,
  });

  final String title;

  /// The chosen subject, or an empty text for none.
  final String subject;
  final DateTime dueDate;
}

/// What the form returns: either the data to save, or "delete this homework".
class HomeworkFormResult {
  const HomeworkFormResult.save(this.data) : isDelete = false;
  const HomeworkFormResult.delete() : data = null, isDelete = true;

  final HomeworkFormData? data;
  final bool isDelete;
}

/// Opens the homework form from the bottom of the screen.
///
/// - Without [initial]: an empty form titled "New homework".
/// - With [initial]: a filled form titled "Edit homework", with a Delete
///   button.
///
/// [subjects] are the quick choices (the subjects from the timetable).
/// Returns null if the user closed the sheet without doing anything.
Future<HomeworkFormResult?> showHomeworkFormSheet(
  BuildContext context, {
  required DateTime today,
  required List<String> subjects,
  HomeworkFormData? initial,
}) {
  return showModalBottomSheet<HomeworkFormResult>(
    context: context,
    isScrollControlled: true, // lets the sheet rise above the keyboard
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _HomeworkFormSheet(
      today: today,
      subjects: subjects,
      initial: initial,
    ),
  );
}

class _HomeworkFormSheet extends StatefulWidget {
  const _HomeworkFormSheet({
    required this.today,
    required this.subjects,
    required this.initial,
  });

  final DateTime today;
  final List<String> subjects;
  final HomeworkFormData? initial;

  @override
  State<_HomeworkFormSheet> createState() => _HomeworkFormSheetState();
}

class _HomeworkFormSheetState extends State<_HomeworkFormSheet> {
  late final TextEditingController _titleController;
  late final DateTime _today;
  late String _subject;
  late DateTime _dueDate;

  bool get _isEditing => widget.initial != null;
  bool get _canSave => _titleController.text.trim().isNotEmpty;

  DateTime get _tomorrow =>
      DateTime(_today.year, _today.month, _today.day + 1);

  @override
  void initState() {
    super.initState();
    _today = Homework.dateOnly(widget.today);

    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _subject = initial?.subject ?? '';
    // A new homework is due tomorrow unless the user says otherwise.
    _dueDate = initial == null ? _tomorrow : Homework.dateOnly(initial.dueDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// The subject chips: the timetable subjects, plus the homework's own
  /// subject if it is no longer in the timetable.
  List<String> get _subjectChoices {
    final choices = List<String>.of(widget.subjects);
    final hasCurrent = choices.any(
      (subject) => subject.toLowerCase() == _subject.toLowerCase(),
    );
    if (_subject.isNotEmpty && !hasCurrent) {
      choices.add(_subject);
    }
    return choices;
  }

  Future<void> _pickDate() async {
    // When editing a late homework its due date is already in the past, so
    // the picker has to be allowed to start that early.
    final firstDate = _dueDate.isBefore(_today) ? _dueDate : _today;

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: firstDate,
      lastDate: DateTime(_today.year + 1, _today.month, _today.day),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() => _dueDate = Homework.dateOnly(picked));
  }

  void _save() {
    if (!_canSave) return;
    Navigator.of(context).pop(
      HomeworkFormResult.save(
        HomeworkFormData(
          title: _titleController.text.trim(),
          subject: _subject,
          dueDate: _dueDate,
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete this homework?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const HomeworkFormResult.delete());
    }
  }

  @override
  Widget build(BuildContext context) {
    final choices = _subjectChoices;
    final isCustomDate = _dueDate != _today && _dueDate != _tomorrow;

    return Padding(
      // Moves the sheet up when the keyboard opens.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Small grab handle at the top of the sheet.
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing ? 'Edit homework' : 'New homework',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // ---- Title ----
              TextField(
                controller: _titleController,
                autofocus: !_isEditing,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                cursorColor: AppColors.primary,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _save(),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Exercises 4 to 7, page 52',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ---- Subject ----
              const _Label('Subject'),
              const SizedBox(height: 8),
              if (choices.isEmpty)
                const Text(
                  'Fill in your timetable first, and your subjects will '
                  'appear here.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final subject in choices)
                      _ChoiceChip(
                        label: subject,
                        color: SubjectColors.of(subject),
                        selected:
                            subject.toLowerCase() == _subject.toLowerCase(),
                        onTap: () {
                          final isSelected =
                              subject.toLowerCase() == _subject.toLowerCase();
                          // Tapping the selected chip again removes it.
                          setState(() => _subject = isSelected ? '' : subject);
                        },
                      ),
                  ],
                ),
              const SizedBox(height: 18),

              // ---- Due date ----
              const _Label('Due'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChoiceChip(
                    label: 'Today',
                    color: _chipBackground,
                    selected: _dueDate == _today,
                    onTap: () => setState(() => _dueDate = _today),
                  ),
                  _ChoiceChip(
                    label: 'Tomorrow',
                    color: _chipBackground,
                    selected: _dueDate == _tomorrow,
                    onTap: () => setState(() => _dueDate = _tomorrow),
                  ),
                  _ChoiceChip(
                    label: isCustomDate
                        ? HomeworkDateText.short(_dueDate)
                        : 'Pick a date',
                    icon: Icons.calendar_today_outlined,
                    color: _chipBackground,
                    selected: isCustomDate,
                    onTap: _pickDate,
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ---- Save ----
              ElevatedButton(
                onPressed: _canSave ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.border,
                  disabledForegroundColor: AppColors.textSecondary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Save changes' : 'Add homework',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // ---- Delete (only when editing) ----
              if (_isEditing) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: const Text(
                    'Delete homework',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.canyon,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A small grey heading above a group of options.
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// A selectable pill, used for both subjects and due dates.
class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.textPrimary),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}