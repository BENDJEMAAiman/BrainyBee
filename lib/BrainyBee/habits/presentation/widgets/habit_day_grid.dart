import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

// Two small shades used only by this grid.
const Color _emptyCell = Color(0xFFF6F1E7); // a day that is not done yet
const Color _disabledText = Color(0xFFC9C2B8); // days that have not come yet

const List<String> _monthNamesShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// DateTime.weekday: Monday = 1 ... Sunday = 7. With `% 7` Sunday becomes 0.
const List<String> _weekdayNamesShort = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
];

/// The 30-day grid shown inside a habit card (cells numbered 1 to 30).
///
/// How it works:
/// 1. The user taps a number. That cell becomes "selected".
/// 2. A small bar appears below the grid with a "Done" button
///    (or "Undo" if that day is already done).
/// 3. Pressing the button reports the change through [onDayToggled]
///    and the selection is cleared.
///
/// This widget does NOT store the habit's data. It only draws what it is
/// given and reports what the user did. The parent (later, the Cubit) owns
/// the data. The only thing this widget remembers is which cell is selected,
/// because that is a purely visual detail.
class HabitDayGrid extends StatefulWidget {
  const HabitDayGrid({
    super.key,
    required this.habit,
    required this.today,
    required this.onDayToggled,
  });

  /// The habit whose completed days are drawn.
  final Habit habit;

  /// The current date. It is passed in (instead of calling DateTime.now()
  /// here) so the widget is easy to test.
  final DateTime today;

  /// Called when the user presses "Done" ([done] = true) or "Undo"
  /// ([done] = false). [day] is the REAL date behind the chosen cell.
  final void Function(DateTime day, bool done) onDayToggled;

  @override
  State<HabitDayGrid> createState() => _HabitDayGridState();
}

class _HabitDayGridState extends State<HabitDayGrid> {
  static const int _columns = 6;

  /// The selected cell number (1-30), or null if nothing is selected.
  int? _selectedNumber;

  @override
  void didUpdateWidget(covariant HabitDayGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If a new round was started, the old selection no longer makes sense.
    if (oldWidget.habit.cycleStart != widget.habit.cycleStart) {
      _selectedNumber = null;
    }
  }

  DateTime _dateFor(int number) => widget.habit.dateForCycleDay(number);

  /// A cell can be tapped only if its day has already arrived.
  bool _isEnabled(int number) {
    final today = Habit.dateOnly(widget.today);
    return !_dateFor(number).isAfter(today);
  }

  void _onCellTapped(int number) {
    setState(() {
      // Tapping the selected cell again unselects it.
      _selectedNumber = (_selectedNumber == number) ? null : number;
    });
  }

  void _onActionPressed(int number) {
    final day = _dateFor(number);
    final isDone = widget.habit.isDoneOn(day);
    widget.onDayToggled(day, !isDone);
    setState(() => _selectedNumber = null);
  }

  @override
  Widget build(BuildContext context) {
    final today = Habit.dateOnly(widget.today);
    final rowCount = (Habit.cycleLength + _columns - 1) ~/ _columns;

    final rows = <Widget>[];
    for (var row = 0; row < rowCount; row++) {
      final cells = <Widget>[];
      for (var col = 0; col < _columns; col++) {
        final number = row * _columns + col + 1;
        if (number > Habit.cycleLength) {
          cells.add(
            const Expanded(
              child: AspectRatio(aspectRatio: 1, child: SizedBox()),
            ),
          );
        } else {
          final day = _dateFor(number);
          cells.add(
            Expanded(
              child: _DayCell(
                number: number,
                isDone: widget.habit.isDoneOn(day),
                isToday: day == today,
                isSelected: number == _selectedNumber,
                isEnabled: _isEnabled(number),
                onTap: () => _onCellTapped(number),
              ),
            ),
          );
        }
      }
      rows.add(Row(children: cells));
    }

    final selected = _selectedNumber;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...rows,

        // The "Done / Undo" bar. It grows in smoothly when a cell is selected.
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: selected == null
              ? const SizedBox(width: double.infinity)
              : _buildActionBar(selected),
        ),
      ],
    );
  }

  Widget _buildActionBar(int number) {
    final day = _dateFor(number);
    final isDone = widget.habit.isDoneOn(day);
    final dateLabel =
        '${_weekdayNamesShort[day.weekday % 7]}, ${day.day} '
        '${_monthNamesShort[day.month - 1]}';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.buttercreamSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $number · $dateLabel',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isDone ? 'Marked as done' : 'Not done yet',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isDone)
            OutlinedButton(
              onPressed: () => _onActionPressed(number),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Undo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          else
            ElevatedButton(
              onPressed: () => _onActionPressed(number),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

/// One numbered cell in the grid.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.number,
    required this.isDone,
    required this.isToday,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final int number;
  final bool isDone;
  final bool isToday;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color textColor;

    if (isDone) {
      background = AppColors.done;
      textColor = AppColors.onDone;
    } else if (isSelected) {
      background = AppColors.canyonSoft;
      textColor = AppColors.textPrimary;
    } else if (isEnabled) {
      background = _emptyCell;
      textColor = isToday ? AppColors.primary : AppColors.textPrimary;
    } else {
      background = Colors.transparent;
      textColor = _disabledText;
    }

    // Today gets a thin ring; the selected cell gets a thicker one.
    final Color borderColor = (isSelected || isToday)
        ? AppColors.primary
        : Colors.transparent;
    final double borderWidth = isSelected ? 2.5 : 1.5;

    final bool bold = isDone || isToday || isSelected;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: AspectRatio(
        aspectRatio: 1,
        child: Semantics(
          button: isEnabled,
          excludeSemantics: true,
          label:
              'Day $number${isToday ? ', today' : ''}${isDone ? ', done' : ''}',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isEnabled ? onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}