import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/hub/model/hub_summary.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/widgets/subject_color.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The Habits card on the main page: today's progress, and a tap to open the
/// Habits page.
class HabitsHubCard extends StatelessWidget {
  const HabitsHubCard({
    super.key,
    required this.done,
    required this.total,
    required this.onTap,
  });

  final int done;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HubCardShell(
      icon: Icons.checklist_rounded,
      iconBackground: AppColors.oliveGroveSoft,
      title: 'Habits',
      onTap: onTap,
      child: total == 0
          ? const Text(
              'No habits yet. Tap to add your first one.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done == total
                      ? 'All habits done today!'
                      : '$done of $total done today',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    // The bar glides to its new length instead of jumping.
                    tween: Tween<double>(end: done / total),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor: AppColors.oliveGroveSoft,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.done,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

/// The Studies card on the main page: the current or next class, how much
/// homework is due today, and a tap to open the Studies page.
///
/// (Late homework is not shown here: the "Latest updates" block says it.)
class StudiesHubCard extends StatelessWidget {
  const StudiesHubCard({
    super.key,
    required this.upcomingClass,
    required this.homeworkDueToday,
    required this.onTap,
  });

  final UpcomingClass? upcomingClass;
  final int homeworkDueToday;
  final VoidCallback onTap;

  Widget _buildClassRow() {
    final next = upcomingClass;
    if (next == null) {
      return const _InfoRow(
        icon: Icons.schedule_rounded,
        child: Text(
          'Fill in your timetable to see your next class.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      );
    }

    return _InfoRow(
      icon: Icons.schedule_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _SubjectTag(subject: next.subject),
          Text(
            next.whenText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: next.isNow ? FontWeight.w800 : FontWeight.w500,
              color: next.isNow
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkRow() {
    if (homeworkDueToday == 0) {
      return const _InfoRow(
        icon: Icons.check_circle_outline_rounded,
        child: Text(
          'No homework due today',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      );
    }

    return _InfoRow(
      icon: Icons.assignment_outlined,
      child: Text(
        '$homeworkDueToday due today',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _HubCardShell(
      icon: Icons.menu_book_rounded,
      iconBackground: AppColors.morningSkySoft,
      title: 'Studies',
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClassRow(),
          const SizedBox(height: 10),
          _buildHomeworkRow(),
        ],
      ),
    );
  }
}

/// The Focus timer card on the main page, with a "Start focus" button.
class FocusHubCard extends StatelessWidget {
  const FocusHubCard({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _HubCardShell(
      icon: Icons.timer_outlined,
      iconBackground: AppColors.buttercreamSoft,
      title: 'Focus timer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pick a duration and study without distractions.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded, size: 24),
            label: const Text(
              'Start focus',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The shared look of every card: a round icon, a title, and the content. If
/// [onTap] is given the whole card is tappable and shows an arrow.
class _HubCardShell extends StatelessWidget {
  const _HubCardShell({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.child,
    this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // A Material so the tap ripple shows.
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconBackground,
                    ),
                    child: Icon(icon, size: 24, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A small icon followed by some content, used for the lines of the Studies
/// card.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
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
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}