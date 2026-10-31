import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/homework_date_text.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/subject_color.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

// Shade used only by this row. (We will move shades like this into AppColors
// when we polish the UI.)
const Color _checkBorder = Color(0xFFB9B0A4);

/// One homework row: a done circle, the title, the subject and due date, and
/// a timer button.
///
/// It owns no data. It reports what the user did through the callbacks.
class HomeworkItem extends StatelessWidget {
  const HomeworkItem({
    super.key,
    required this.homework,
    required this.today,
    required this.onToggleDone,
    required this.onTap,
    required this.onStartTimer,
  });

  final Homework homework;
  final DateTime today;

  /// The user tapped the round circle (done <-> not done).
  final VoidCallback onToggleDone;

  /// The user tapped the row itself (the screen opens the edit form).
  final VoidCallback onTap;

  /// The user tapped the timer button.
  final VoidCallback onStartTimer;

  @override
  Widget build(BuildContext context) {
    final status = homework.statusOn(today);
    final isDone =
        status == HomeworkStatus.doneToday ||
        status == HomeworkStatus.archived;
    final isMissed = status == HomeworkStatus.missed;
    final isDueToday =
        status == HomeworkStatus.todo && homework.daysUntilDue(today) == 0;

    final Color dueColor;
    if (isMissed) {
      dueColor = AppColors.missedText;
    } else if (isDueToday) {
      dueColor = AppColors.textPrimary;
    } else {
      dueColor = AppColors.textSecondary;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            _CheckCircle(
              isDone: isDone,
              label: isDone
                  ? 'Mark ${homework.title} as not done'
                  : 'Mark ${homework.title} as done',
              onTap: onToggleDone,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    homework.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDone
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (homework.subject.isNotEmpty)
                        _SubjectTag(subject: homework.subject),
                      Text(
                        HomeworkDateText.dueLabel(homework, today),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: (isMissed || isDueToday)
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: dueColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isDone) ...[
              const SizedBox(width: 8),
              _TimerButton(onPressed: onStartTimer),
            ],
          ],
        ),
      ),
    );
  }
}

/// The round "done" control on the left. The tap area is 44 x 44 so it is
/// easy to hit with a thumb, even though the circle itself is smaller.
class _CheckCircle extends StatelessWidget {
  const _CheckCircle({
    required this.isDone,
    required this.label,
    required this.onTap,
  });

  final bool isDone;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: isDone,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.done : Colors.transparent,
                border: Border.all(
                  color: isDone ? AppColors.done : _checkBorder,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: AppColors.onDone,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// The small colored subject label, e.g. "Math".
class _SubjectTag extends StatelessWidget {
  const _SubjectTag({required this.subject});

  final String subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: SubjectColors.of(subject),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        subject,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// The round timer button on the right.
class _TimerButton extends StatelessWidget {
  const _TimerButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Start a timer',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.buttercreamSoft,
          ),
          child: const Icon(
            Icons.timer_outlined,
            size: 22,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}