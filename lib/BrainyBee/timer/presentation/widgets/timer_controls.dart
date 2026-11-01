import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/timer/model/timer_model.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The buttons under the ring while the timer is idle, running or paused.
/// (When the timer has finished, [TimerFinishedPanel] is shown instead.)
class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
  });

  final TimerStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TimerStatus.idle:
        return _PrimaryButton(
          label: 'Start',
          icon: Icons.play_arrow_rounded,
          onPressed: onStart,
        );

      case TimerStatus.running:
        return Row(
          children: [
            Expanded(
              child: _SecondaryButton(label: 'Reset', onPressed: onReset),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _PrimaryButton(
                label: 'Pause',
                icon: Icons.pause_rounded,
                onPressed: onPause,
              ),
            ),
          ],
        );

      case TimerStatus.paused:
        return Row(
          children: [
            Expanded(
              child: _SecondaryButton(label: 'Reset', onPressed: onReset),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _PrimaryButton(
                label: 'Resume',
                icon: Icons.play_arrow_rounded,
                onPressed: onResume,
              ),
            ),
          ],
        );

      case TimerStatus.finished:
        return const SizedBox.shrink();
    }
  }
}

/// The card shown when a session or a break has ended.
///
/// After a FOCUS session it offers: mark the homework done (only when the
/// timer was opened for a homework), start a short break, or finish.
/// After a BREAK it offers: start another session, or finish.
class TimerFinishedPanel extends StatelessWidget {
  const TimerFinishedPanel({
    super.key,
    required this.snapshot,
    required this.hasHomework,
    required this.onMarkHomeworkDone,
    required this.onStartBreak,
    required this.onStartAnother,
    required this.onFinish,
  });

  final TimerSnapshot snapshot;

  /// True if the timer was opened for a specific homework.
  final bool hasHomework;

  final VoidCallback onMarkHomeworkDone;
  final VoidCallback onStartBreak;

  /// Go back to the "choose a duration" state to start a new session.
  final VoidCallback onStartAnother;

  /// Leave the timer page.
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final afterFocus = snapshot.phase == TimerPhase.focus;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.done,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 32,
                color: AppColors.onDone,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            afterFocus ? 'Session complete!' : 'Break is over',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            afterFocus
                ? 'You focused for ${snapshot.totalMinutes} minutes.'
                : 'Ready for another round?',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          if (afterFocus) ...[
            if (hasHomework) ...[
              _PrimaryButton(
                label: 'Mark homework as done',
                icon: Icons.check_circle_outline_rounded,
                onPressed: onMarkHomeworkDone,
              ),
              const SizedBox(height: 10),
              _SecondaryButton(
                label: 'Start a ${TimerPresets.breakMinutes} min break',
                onPressed: onStartBreak,
              ),
            ] else
              _PrimaryButton(
                label: 'Start a ${TimerPresets.breakMinutes} min break',
                icon: Icons.free_breakfast_outlined,
                onPressed: onStartBreak,
              ),
          ] else
            _PrimaryButton(
              label: 'Start another session',
              icon: Icons.play_arrow_rounded,
              onPressed: onStartAnother,
            ),

          const SizedBox(height: 6),
          TextButton(
            onPressed: onFinish,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Finish',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// The big orange button.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

    if (icon == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: Text(label, style: textStyle),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label, style: textStyle),
      style: style,
    );
  }
}

/// The quieter outlined button.
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}