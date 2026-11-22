import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/subject_color.dart';
import 'package:mobile_app_project/BrainyBee/timer/model/timer_model.dart';
import 'package:mobile_app_project/BrainyBee/timer/presentation/widgets/duration_picker.dart';
import 'package:mobile_app_project/BrainyBee/timer/presentation/widgets/timer_controls.dart';
import 'package:mobile_app_project/BrainyBee/timer/presentation/widgets/timer_ring.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The timer page: a big countdown ring, a duration choice, and buttons.
///
/// This screen owns NO timing logic. It draws the [snapshot] it receives and
/// reports what the user did through the callbacks. The [TimerCubit] (through
/// the timer page) does the real counting.
///
/// If [homeworkTitle] is given, a "Working on" card shows it, and the finished
/// panel offers to mark that homework as done (unless [homeworkMarkedDone]).
class TimerScreen extends StatelessWidget {
  const TimerScreen({
    super.key,
    required this.snapshot,
    required this.onSelectMinutes,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onStartBreak,
    required this.onMarkHomeworkDone,
    required this.onFinish,
    this.homeworkTitle,
    this.homeworkSubject,
    this.homeworkMarkedDone = false,
  });

  final TimerSnapshot snapshot;

  /// The homework this session is for, if any.
  final String? homeworkTitle;
  final String? homeworkSubject;

  /// True once the homework was marked done, so the button is not offered
  /// again.
  final bool homeworkMarkedDone;

  /// The user chose a focus length (only possible before starting).
  final ValueChanged<int> onSelectMinutes;

  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;

  /// Stop and go back to "choose a duration".
  final VoidCallback onReset;

  /// Start the short break after a finished focus session.
  final VoidCallback onStartBreak;

  /// The user said the homework is done (from the finished panel).
  final VoidCallback onMarkHomeworkDone;

  /// The user wants to leave the timer page (X button or "Finish").
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final title = homeworkTitle;
    final canChooseDuration =
        snapshot.status == TimerStatus.idle &&
        snapshot.phase == TimerPhase.focus;
    final isFinished = snapshot.status == TimerStatus.finished;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: onFinish,
        ),
        title: const Text(
          'Focus timer',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          // Keeps the layout tidy on wide screens (e.g. Chrome).
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  _HomeworkCard(title: title, subject: homeworkSubject ?? ''),
                  const SizedBox(height: 28),
                ],

                TimerRing(snapshot: snapshot),
                const SizedBox(height: 28),

                if (canChooseDuration) ...[
                  DurationPicker(
                    minutes: snapshot.totalMinutes,
                    onChanged: onSelectMinutes,
                  ),
                  const SizedBox(height: 24),
                ],

                if (isFinished)
                  TimerFinishedPanel(
                    snapshot: snapshot,
                    hasHomework: title != null && !homeworkMarkedDone,
                    onMarkHomeworkDone: onMarkHomeworkDone,
                    onStartBreak: onStartBreak,
                    onStartAnother: onReset,
                    onFinish: onFinish,
                  )
                else
                  TimerControls(
                    status: snapshot.status,
                    onStart: onStart,
                    onPause: onPause,
                    onResume: onResume,
                    onReset: onReset,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The small card at the top: "Working on" and the homework's title.
class _HomeworkCard extends StatelessWidget {
  const _HomeworkCard({required this.title, required this.subject});

  final String title;
  final String subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.morningSkySoft,
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Working on',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (subject.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
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
            ),
          ],
        ],
      ),
    );
  }
}