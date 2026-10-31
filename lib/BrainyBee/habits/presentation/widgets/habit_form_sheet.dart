import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/habits/presentation/widgets/habit_icons.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// What the user typed and picked in the habit form.
class HabitFormData {
  const HabitFormData({required this.name, required this.iconKey});

  final String name;
  final String iconKey;
}

/// Opens the habit form from the bottom of the screen.
///
/// - Without [initial]: the form is empty and says "New habit".
/// - With [initial]: the form is pre-filled and says "Edit habit".
///
/// Returns the data if the user pressed the save button, or null if they
/// closed the sheet without saving.
Future<HabitFormData?> showHabitFormSheet(
  BuildContext context, {
  HabitFormData? initial,
}) {
  return showModalBottomSheet<HabitFormData>(
    context: context,
    isScrollControlled: true, // lets the sheet rise above the keyboard
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _HabitFormSheet(initial: initial),
  );
}

class _HabitFormSheet extends StatefulWidget {
  const _HabitFormSheet({this.initial});

  final HabitFormData? initial;

  @override
  State<_HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends State<_HabitFormSheet> {
  late final TextEditingController _nameController;
  late String _iconKey;

  bool get _isEditing => widget.initial != null;
  bool get _canSave => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial?.name ?? '');
    _iconKey = widget.initial?.iconKey ?? HabitIcons.keys.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_canSave) return;
    Navigator.of(context).pop(
      HabitFormData(name: _nameController.text.trim(), iconKey: _iconKey),
    );
  }

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
                _isEditing ? 'Edit habit' : 'New habit',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // ---- Name ----
              TextField(
                controller: _nameController,
                autofocus: true,
                maxLength: 40,
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
                  hintText: 'e.g. Read 15 minutes',
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

              // ---- Icon picker ----
              const Text(
                'Pick an icon',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final key in HabitIcons.keys)
                    _IconChoice(
                      iconKey: key,
                      isSelected: key == _iconKey,
                      onTap: () => setState(() => _iconKey = key),
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
                  _isEditing ? 'Save changes' : 'Add habit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One selectable icon in the picker.
class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.iconKey,
    required this.isSelected,
    required this.onTap,
  });

  final String iconKey;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = HabitIcons.styleFor(iconKey);

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Icon $iconKey',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Icon(style.icon, color: AppColors.textPrimary, size: 26),
        ),
      ),
    );
  }
}