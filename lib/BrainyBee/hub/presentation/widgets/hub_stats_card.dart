import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/hub/model/hub_stats.dart';
import 'package:mobile_app_project/BrainyBee/hub/presentation/widgets/stats_charts.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

// Weekday letters, Sunday first. DateTime.weekday is Monday = 1 ... Sunday = 7,
// so `% 7` makes Sunday 0.
const List<String> _weekdayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

/// The "Your week" card: charts for the habits and for the homework of the
/// last 7 days. A section is left out when it has nothing to show.
class HubStatsCard extends StatelessWidget {
  const HubStatsCard({super.key, required this.stats});

  final HubStats stats;

  @override
  Widget build(BuildContext context) {
    final habits = stats.habits;
    final homework = stats.homework;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Your week',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'Last 7 days',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (habits != null) _HabitsSection(stats: habits),

            if (habits != null && homework != null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Divider(height: 1, color: AppColors.border),
              ),

            if (homework != null) _HomeworkSection(stats: homework),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Habits
// ---------------------------------------------------------------------------

class _HabitsSection extends StatelessWidget {
  const _HabitsSection({required this.stats});

  final HabitStats stats;

  /// How many habits the "By habit" chart lists.
  static const int _maxRates = 5;

  @override
  Widget build(BuildContext context) {
    final lastIndex = stats.days.length - 1;
    final dayItems = [
      for (var i = 0; i < stats.days.length; i++)
        BarChartItem(
          label: _weekdayLetters[stats.days[i].date.weekday % 7],
          value: stats.days[i].fraction * 100,
          valueLabel: stats.days[i].total == 0
              ? '–'
              : '${stats.days[i].percent}%',
          highlight: i == lastIndex,
        ),
    ];

    final shownRates = stats.rates.take(_maxRates).toList();
    final hiddenRates = stats.rates.length - shownRates.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.checklist_rounded, text: 'Habits'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatPill(
              label: 'Average',
              value: '${stats.weekPercent}%',
              background: AppColors.oliveGroveSoft,
            ),
            _StatPill(
              label: 'Best streak',
              value: '${stats.bestStreak}',
              background: AppColors.buttercreamSoft,
            ),
            _StatPill(
              label: 'Perfect days',
              value: '${stats.perfectDays}/${stats.daysWithHabits}',
              background: AppColors.morningSkySoft,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _ChartTitle('Daily completion'),
        const SizedBox(height: 10),
        StatsBarChart(items: dayItems, maxValue: 100, barColor: AppColors.done),

        if (shownRates.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _ChartTitle('By habit'),
          const SizedBox(height: 10),
          StatsRateBars(
            barColor: AppColors.done,
            items: [
              for (final rate in shownRates)
                RateBarItem(
                  label: rate.name,
                  fraction: rate.percent / 100,
                  valueLabel: '${rate.percent}%',
                ),
            ],
          ),
          if (hiddenRates > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                hiddenRates == 1 ? '+1 more habit' : '+$hiddenRates more habits',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Homework
// ---------------------------------------------------------------------------

class _HomeworkSection extends StatelessWidget {
  const _HomeworkSection({required this.stats});

  final HomeworkStats stats;

  @override
  Widget build(BuildContext context) {
    final maxCount = stats.donePerDay.fold<int>(
      0,
      (biggest, day) => day.count > biggest ? day.count : biggest,
    );
    final lastIndex = stats.donePerDay.length - 1;

    final dayItems = [
      for (var i = 0; i < stats.donePerDay.length; i++)
        BarChartItem(
          label: _weekdayLetters[stats.donePerDay[i].date.weekday % 7],
          value: stats.donePerDay[i].count.toDouble(),
          valueLabel: '${stats.donePerDay[i].count}',
          highlight: i == lastIndex,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.menu_book_rounded, text: 'Homework'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatPill(
              label: 'On time',
              value: stats.onTimePercent == null
                  ? '–'
                  : '${stats.onTimePercent}%',
              background: AppColors.morningSkySoft,
            ),
            _StatPill(
              label: 'Done',
              value: '${stats.doneLast7Days}',
              background: AppColors.oliveGroveSoft,
            ),
            _StatPill(
              label: 'Late now',
              value: '${stats.lateNow}',
              background: stats.lateNow > 0
                  ? AppColors.missed.withValues(alpha: 0.12)
                  : AppColors.background,
              valueColor: stats.lateNow > 0
                  ? AppColors.missedText
                  : AppColors.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _ChartTitle('Done per day'),
        const SizedBox(height: 10),
        StatsBarChart(
          items: dayItems,
          // At least 3, so a single finished task does not fill a whole bar.
          maxValue: maxCount < 3 ? 3 : maxCount.toDouble(),
          barColor: AppColors.done,
        ),
        const SizedBox(height: 20),
        const _ChartTitle('Status'),
        const SizedBox(height: 10),
        if (stats.total == 0)
          const Text(
            'No recent homework.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          )
        else
          StatsDonut(
            centerValue: '${stats.total}',
            centerLabel: stats.total == 1 ? 'task' : 'tasks',
            segments: [
              DonutSegment(
                label: 'Done',
                value: stats.doneLast7Days,
                color: AppColors.done,
              ),
              DonutSegment(
                label: 'To do',
                value: stats.todoCount,
                color: AppColors.morningSky,
              ),
              DonutSegment(
                label: 'Late',
                value: stats.lateNow,
                color: AppColors.missed,
              ),
            ],
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Small pieces shared by both sections
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ChartTitle extends StatelessWidget {
  const _ChartTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// A small rounded label with a bold value, e.g. "Average 71%".
class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.background,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color background;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}