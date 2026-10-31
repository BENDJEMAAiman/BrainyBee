import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/widgets/habit_progress.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

const Color _barTrack = Color(0xFFF6F1E7);

// DateTime.weekday: Monday = 1 ... Sunday = 7. With `% 7` Sunday becomes 0.
const List<String> _weekdayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
const List<String> _weekdayNames = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

/// A simple bar chart: one bar per day, showing how many habits were done.
///
/// It only draws the numbers it receives in [days] (oldest first, last = today).
/// The calculation lives in [HabitProgress], not here.
class HabitProgressChart extends StatelessWidget {
  const HabitProgressChart({
    super.key,
    required this.days,
    required this.today,
  });

  final List<DayProgress> days;
  final DateTime today;

  static const double _barHeight = 100;

  @override
  Widget build(BuildContext context) {
    final hasHabits = days.any((day) => day.total > 0);
    final average = HabitProgress.averagePercent(days);
    final todayOnly = Habit.dateOnly(today);

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
          // ---- Header: title on the left, average on the right ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Last 7 days',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasHabits)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$average%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'average',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (!hasHabits)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Add a habit to see your progress here.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in days)
                  Expanded(
                    child: _DayBar(
                      day: day,
                      isToday: day.date == todayOnly,
                      barHeight: _barHeight,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// One column of the chart: percent label, bar, weekday letter.
class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.isToday,
    required this.barHeight,
  });

  final DayProgress day;
  final bool isToday;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final weekdayIndex = day.date.weekday % 7;
    final label = day.total == 0 ? '–' : '${day.percent}%';

    return Semantics(
      label: '${_weekdayNames[weekdayIndex]}: '
          '${day.total == 0 ? 'no habits' : '${day.percent} percent done'}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: barHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: _barTrack,
                  alignment: Alignment.bottomCenter,
                  // Animates smoothly whenever the value changes.
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: day.fraction),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return FractionallySizedBox(
                        widthFactor: 1,
                        heightFactor: value.clamp(0.0, 1.0),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.done),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _weekdayLetters[weekdayIndex],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                color: isToday ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}