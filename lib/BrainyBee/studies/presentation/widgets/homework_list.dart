import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/homework_item.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The whole homework card: a title with an "Add" button, then the sections
/// To do, Missed (red container) and Done today (green container).
///
/// It owns no data. It draws the [homeworks] it receives and reports what the
/// user did through the callbacks.
class HomeworkList extends StatelessWidget {
  const HomeworkList({
    super.key,
    required this.homeworks,
    required this.today,
    required this.onAdd,
    required this.onToggleDone,
    required this.onEdit,
    required this.onStartTimer,
  });

  final List<Homework> homeworks;
  final DateTime today;

  /// The user pressed "Add".
  final VoidCallback onAdd;

  /// The user tapped the done circle of [homework].
  final void Function(Homework homework) onToggleDone;

  /// The user tapped the row of [homework] (open the edit form).
  final void Function(Homework homework) onEdit;

  /// The user tapped the timer button of [homework].
  final void Function(Homework homework) onStartTimer;

  /// Builds the rows of one section, with a thin divider between them.
  List<Widget> _buildItems(List<Homework> items, {required Color dividerColor}) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final homework = items[i];
      widgets.add(
        HomeworkItem(
          key: ValueKey(homework.id),
          homework: homework,
          today: today,
          onToggleDone: () => onToggleDone(homework),
          onTap: () => onEdit(homework),
          onStartTimer: () => onStartTimer(homework),
        ),
      );
      if (i < items.length - 1) {
        widgets.add(Divider(height: 1, color: dividerColor));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final groups = HomeworkGroups.from(homeworks, today);

    // A Material (instead of a plain Container) so the rows' tap ripples show.
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Title and Add button ----
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Homework',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),

            if (groups.isEmpty)
              const _EmptyMessage()
            else ...[
              // ---- To do (plain white card) ----
              _SectionHeader(
                title: 'To do',
                count: groups.todo.length,
                icon: Icons.radio_button_unchecked_rounded,
                color: AppColors.textPrimary,
              ),
              if (groups.todo.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Nothing left to do. Nice work!',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ..._buildItems(groups.todo, dividerColor: AppColors.border),

              // ---- Missed (fades from transparent to red) ----
              if (groups.missed.isNotEmpty)
                _TintedGroup(
                  color: AppColors.missed,
                  children: [
                    _SectionHeader(
                      title: 'Missed',
                      count: groups.missed.length,
                      icon: Icons.error_outline_rounded,
                      color: AppColors.missedText,
                      topPadding: 8,
                    ),
                    ..._buildItems(
                      groups.missed,
                      dividerColor: AppColors.missed.withValues(alpha: 0.25),
                    ),
                  ],
                ),

              // ---- Done today (fades from transparent to green) ----
              if (groups.doneToday.isNotEmpty)
                _TintedGroup(
                  color: AppColors.done,
                  children: [
                    _SectionHeader(
                      title: 'Done today',
                      count: groups.doneToday.length,
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.doneText,
                      topPadding: 8,
                    ),
                    ..._buildItems(
                      groups.doneToday,
                      dividerColor: AppColors.done.withValues(alpha: 0.35),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A rounded box that fades from fully transparent (top) to a soft [color]
/// (bottom), with a thin outline in the same color.
///
/// To make the fade go left to right instead, change `begin` and `end` to
/// Alignment.centerLeft and Alignment.centerRight.
class _TintedGroup extends StatelessWidget {
  const _TintedGroup({required this.color, required this.children});

  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.18)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// The small heading above each section: icon, name and a count.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.topPadding = 16,
  });

  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when there is no homework to display at all.
class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.task_alt_rounded, size: 44, color: AppColors.canyon),
          SizedBox(height: 12),
          Text(
            'No homework right now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tap "Add" when you get some.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}