import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/widgets/habit_card.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/widgets/habit_form_sheet.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/widgets/habit_progress.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/widgets/habit_progress_chart.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The Habits page: every habit as a card, the progress chart under them, and
/// an "Add habit" button.
///
/// This screen owns NO data. It draws the [habits] it receives and reports
/// what the user did through the callbacks. For now a preview file supplies
/// dummy data; later the Cubit will supply the real list and handle the
/// callbacks.
class HabitsScreen extends StatelessWidget {
  const HabitsScreen({
    super.key,
    required this.habits,
    required this.today,
    required this.onDayToggled,
    required this.onNewCycle,
    required this.onAddHabit,
    required this.onEditHabit,
    required this.onDeleteHabit,
  });

  final List<Habit> habits;
  final DateTime today;

  /// A day of [habit] was marked done ([done] = true) or undone.
  final void Function(Habit habit, DateTime day, bool done) onDayToggled;

  /// The user confirmed a new 30-day round for [habit].
  final void Function(Habit habit) onNewCycle;

  /// The user filled in the "new habit" form.
  final void Function(String name, String iconKey) onAddHabit;

  /// The user saved changes to [habit] in the edit form.
  final void Function(Habit habit, String name, String iconKey) onEditHabit;

  /// The user confirmed deleting [habit].
  final void Function(Habit habit) onDeleteHabit;

  Future<void> _openAddSheet(BuildContext context) async {
    final data = await showHabitFormSheet(context);
    if (data != null) {
      onAddHabit(data.name, data.iconKey);
    }
  }

  Future<void> _openEditSheet(BuildContext context, Habit habit) async {
    final data = await showHabitFormSheet(
      context,
      initial: HabitFormData(name: habit.name, iconKey: habit.iconKey),
    );
    if (data != null) {
      onEditHabit(habit, data.name, data.iconKey);
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
          'My habits',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add habit',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          // Keeps the layout tidy on wide screens (e.g. Chrome).
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            // Extra bottom space so the button never hides the last card.
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              if (habits.isEmpty)
                const _EmptyState()
              else ...[
                for (final habit in habits) ...[
                  HabitCard(
                    // The key keeps each card's state (like the selected day)
                    // attached to the right habit when one is deleted.
                    key: ValueKey(habit.id),
                    habit: habit,
                    today: today,
                    onDayToggled: (day, done) =>
                        onDayToggled(habit, day, done),
                    onNewCycle: () => onNewCycle(habit),
                    onEdit: () => _openEditSheet(context, habit),
                    onDelete: () => onDeleteHabit(habit),
                  ),
                  const SizedBox(height: 16),
                ],
                HabitProgressChart(
                  days: HabitProgress.lastDays(habits, today),
                  today: today,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when there are no habits yet.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.checklist_rounded, size: 56, color: AppColors.canyon),
          SizedBox(height: 16),
          Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tap "Add habit" to start your first 30-day round.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}