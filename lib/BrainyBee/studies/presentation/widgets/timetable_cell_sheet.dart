import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/subject_color.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// Opens the cell editor from the bottom of the screen.
///
/// What it returns:
/// - a text    -> the user pressed Save: put this text in the cell
/// - '' (empty) -> the user pressed Clear: empty the cell
/// - null      -> the user closed the sheet: change nothing
Future<String?> showTimetableCellSheet(
  BuildContext context, {
  required String title,
  required String initial,
  required List<String> suggestions,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true, // lets the sheet rise above the keyboard
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _TimetableCellSheet(
      title: title,
      initial: initial,
      suggestions: suggestions,
    ),
  );
}

class _TimetableCellSheet extends StatefulWidget {
  const _TimetableCellSheet({
    required this.title,
    required this.initial,
    required this.suggestions,
  });

  final String title;
  final String initial;
  final List<String> suggestions;

  @override
  State<_TimetableCellSheet> createState() => _TimetableCellSheetState();
}

class _TimetableCellSheetState extends State<_TimetableCellSheet> {
  late final TextEditingController _controller;

  bool get _hasInitial => widget.initial.trim().isNotEmpty;
  bool get _canSave => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickSuggestion(String subject) {
    setState(() {
      _controller.text = subject;
      _controller.selection = TextSelection.collapsed(offset: subject.length);
    });
  }

  void _save() {
    if (!_canSave) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  void _clear() => Navigator.of(context).pop('');

  @override
  Widget build(BuildContext context) {
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
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // ---- Subject text ----
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 14,
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
                  hintText: 'e.g. Math',
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

              // ---- Subjects already used in the table ----
              if (widget.suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Your subjects',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final subject in widget.suggestions)
                      _SubjectChip(
                        subject: subject,
                        onTap: () => _pickSuggestion(subject),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 22),

              // ---- Buttons ----
              Row(
                children: [
                  if (_hasInitial) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clear,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
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
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tappable subject in the "Your subjects" list, in the subject's color.
class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.subject, required this.onTap});

  final String subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Use $subject',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: SubjectColors.of(subject),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            subject,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}