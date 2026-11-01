import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/timer/model/timer_model.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The big circle with the time in the middle. The colored arc shrinks as time
/// runs out: orange for a focus session, blue for a break.
class TimerRing extends StatelessWidget {
  const TimerRing({super.key, required this.snapshot});

  final TimerSnapshot snapshot;

  /// The small text under the time.
  String get _label {
    switch (snapshot.status) {
      case TimerStatus.idle:
        return 'Ready to focus';
      case TimerStatus.running:
        return snapshot.phase == TimerPhase.focus ? 'Focus' : 'Break';
      case TimerStatus.paused:
        return 'Paused';
      case TimerStatus.finished:
        return snapshot.phase == TimerPhase.focus
            ? 'Session complete'
            : 'Break is over';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFocus = snapshot.phase == TimerPhase.focus;
    final progressColor = isFocus ? AppColors.primary : AppColors.morningSky;
    final trackColor = isFocus
        ? AppColors.canyonSoft
        : AppColors.morningSkySoft;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: AspectRatio(
          aspectRatio: 1,
          child: Semantics(
            label: 'Time left ${snapshot.clockText}. $_label',
            child: ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                // The arc glides to its new length instead of jumping.
                tween: Tween<double>(end: snapshot.remainingFraction),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return CustomPaint(
                    painter: _RingPainter(
                      progress: value,
                      progressColor: progressColor,
                      trackColor: trackColor,
                      strokeWidth: 16,
                    ),
                    child: child,
                  );
                },
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        snapshot.clockText,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          // Every digit gets the same width, so the time does
                          // not wobble as the numbers change.
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the grey-ish track circle and, on top of it, the colored arc.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  /// From 1.0 (full circle) down to 0.0 (no arc).
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final arc = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start at the top (-90 degrees) and sweep clockwise.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}