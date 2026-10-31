import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/widgets/habit_day_grid.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/widgets/habit_icons.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

enum _HabitMenuAction { edit, delete }

/// One habit on the Habits page: icon, name, streak, a ⋮ menu (edit/delete),
/// the 30-day grid, and a refresh button at the bottom right to start a new
/// round.
///
/// Like the grid, this widget only draws and reports. It owns no data. It does
/// ask for confirmation before the two actions that are hard to take back
/// (new round and delete) and only reports them once the user confirms.
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.today,
    required this.onDayToggled,
    required this.onNewCycle,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final DateTime today;

  /// A day was marked done ([done] = true) or undone ([done] = false).
  final void Function(DateTime day, bool done) onDayToggled;

  /// The user confirmed that they want a new 30-day round.
  final VoidCallback onNewCycle;

  /// The user chose "Edit" in the menu. The screen opens the edit form.
  final VoidCallback onEdit;

  /// The user confirmed that they want to delete this habit.
  final VoidCallback onDelete;

  Future<void> _confirmNewCycle(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Start a new 30-day round?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'The grid will start again from today. '
          'Your past progress and your streak are kept.',
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
              'Start new round',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onNewCycle();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete "${habit.name}"?',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This permanently deletes the habit and all of its progress. '
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

    if (confirmed == true) {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconStyle = HabitIcons.styleFor(habit.iconKey);
    final streak = habit.currentStreak(today);
    final isFinished = habit.isCycleFinished(today);
    final doneCount = habit.doneCountInCycle();

    final statusText = isFinished
        ? 'Round finished · $doneCount of ${Habit.cycleLength} done'
        : 'Day ${habit.cycleDayNumber(today).clamp(1, Habit.cycleLength)} '
              'of ${Habit.cycleLength} · $doneCount done';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Header: icon, name, streak, menu ----
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconStyle.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  iconStyle.icon,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  habit.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (streak > 0) ...[
                const SizedBox(width: 8),
                _StreakChip(streak: streak),
              ],
              _buildMenu(context),
            ],
          ),
          const SizedBox(height: 14),

          // ---- The 30-day grid ----
          HabitDayGrid(
            habit: habit,
            today: today,
            onDayToggled: onDayToggled,
          ),
          const SizedBox(height: 10),

          // ---- Footer: status text and refresh button (bottom right) ----
          Row(
            children: [
              Expanded(
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              _RefreshButton(
                highlighted: isFinished,
                onPressed: () => _confirmNewCycle(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<_HabitMenuAction>(
      tooltip: 'More options',
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.textSecondary,
      ),
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (action) {
        if (action == _HabitMenuAction.edit) {
          onEdit();
        } else {
          _confirmDelete(context);
        }
      },
      itemBuilder: (menuContext) => const [
        PopupMenuItem<_HabitMenuAction>(
          value: _HabitMenuAction.edit,
          child: _MenuRow(
            icon: Icons.edit_outlined,
            label: 'Edit',
            color: AppColors.textPrimary,
          ),
        ),
        PopupMenuItem<_HabitMenuAction>(
          value: _HabitMenuAction.delete,
          child: _MenuRow(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            color: AppColors.canyon,
          ),
        ),
      ],
    );
  }
}

/// One line of the ⋮ menu: an icon and a label.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

/// Small badge such as "🔥 5" showing the current streak.
class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.buttercreamSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 18,
            color: AppColors.canyon,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The refresh button. A quiet round icon normally; once the 30 days are over
/// it becomes a highlighted "New round" button to tell the user it is time.
class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.highlighted, required this.onPressed});

  final bool highlighted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (highlighted) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text(
          'New round',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    return Tooltip(
      message: 'Start a new 30-day round',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}