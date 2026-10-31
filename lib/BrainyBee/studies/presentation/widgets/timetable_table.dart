import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/subject_color.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

// Two small shades used only by this table. (We will move shades like these
// into AppColors when we polish the UI.)
const Color _emptyCell = Color(0xFFF6F1E7);
const Color _mutedIcon = Color(0xFFC9C2B8);

const double _timeColumnWidth = 44;
const double _cellHeight = 52;

/// The weekly timetable: 5 day columns (Sunday to Thursday) and 7 session
/// rows, with a break row between the morning and the afternoon.
///
/// It owns no data. It draws the [timetable] it receives and reports taps
/// through [onCellTap]. [now] is passed in (not read from the clock here) so
/// the widget is easy to test; it is used to highlight today's column and the
/// session happening right now.
class TimetableTable extends StatelessWidget {
  const TimetableTable({
    super.key,
    required this.timetable,
    required this.now,
    required this.onCellTap,
  });

  final Timetable timetable;
  final DateTime now;

  /// The user tapped the cell at [day] (0-4) and [slot] (0-6).
  final void Function(int day, int slot) onCellTap;

  @override
  Widget build(BuildContext context) {
    final todayDay = TimetableLayout.dayIndexFor(now);
    final currentSlot = TimetableLayout.slotIndexFor(now);

    final rows = <Widget>[];
    for (var slot = 0; slot < TimetableLayout.slotCount; slot++) {
      rows.add(
        Row(
          children: [
            SizedBox(
              width: _timeColumnWidth,
              child: Center(
                child: Text(
                  TimetableLayout.slotLabel(slot),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            for (var day = 0; day < TimetableLayout.dayCount; day++)
              Expanded(
                child: _TimetableCell(
                  subject: timetable.subjectAt(day, slot),
                  semanticsLabel:
                      '${TimetableLayout.dayNames[day]} '
                      '${TimetableLayout.slotLabel(slot)}',
                  isNow: day == todayDay && slot == currentSlot,
                  onTap: () => onCellTap(day, slot),
                ),
              ),
          ],
        ),
      );

      if (slot == TimetableLayout.breakAfterSlot) {
        rows.add(const _BreakRow());
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Title and hint ----
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Timetable',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'Tap a cell to edit',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---- Day names ----
          Row(
            children: [
              const SizedBox(width: _timeColumnWidth),
              for (var day = 0; day < TimetableLayout.dayCount; day++)
                Expanded(
                  child: _DayHeader(
                    label: TimetableLayout.dayShortNames[day],
                    isToday: day == todayDay,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),

          // ---- Session rows ----
          ...rows,
        ],
      ),
    );
  }
}

/// "Sun", "Mon", ... above each column. Today's column is highlighted.
class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label, required this.isToday});

  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isToday ? AppColors.canyonSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isToday ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// The thin row between the morning and the afternoon sessions.
class _BreakRow extends StatelessWidget {
  const _BreakRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: _timeColumnWidth,
            child: Center(
              child: Text(
                TimetableLayout.breakLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: _mutedIcon,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Break',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _mutedIcon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One tappable cell: the subject name in its color, or a faint "+" if empty.
class _TimetableCell extends StatelessWidget {
  const _TimetableCell({
    required this.subject,
    required this.semanticsLabel,
    required this.isNow,
    required this.onTap,
  });

  final String subject;
  final String semanticsLabel;

  /// True for the session happening right now (gets an orange ring).
  final bool isNow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasSubject = subject.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Semantics(
        button: true,
        label: '$semanticsLabel: ${hasSubject ? subject : 'empty'}',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: _cellHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: hasSubject ? SubjectColors.of(subject) : _emptyCell,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isNow ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: hasSubject
                ? Text(
                    subject,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Icon(Icons.add_rounded, size: 16, color: _mutedIcon),
          ),
        ),
      ),
    );
  }
}