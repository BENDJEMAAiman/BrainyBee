import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/hub/model/hub_updates.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The "Latest updates" block: up to three rows, each tappable and tinted by
/// its tone (red = needs action, yellow = heads-up, green = good news).
///
/// It owns no data. It draws the [updates] it receives and reports taps.
class LatestUpdatesCard extends StatelessWidget {
  const LatestUpdatesCard({
    super.key,
    required this.updates,
    required this.onOpenHabits,
    required this.onOpenStudies,
  });

  final List<HubUpdate> updates;
  final VoidCallback onOpenHabits;
  final VoidCallback onOpenStudies;

  void _open(HubUpdate update) {
    if (update.target == UpdateTarget.habits) {
      onOpenHabits();
    } else if (update.target == UpdateTarget.studies) {
      onOpenStudies();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Icon(
                  Icons.notifications_none_rounded,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 8),
                Text(
                  'Latest updates',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < updates.length; i++) ...[
              _UpdateRow(update: updates[i], onTap: () => _open(updates[i])),
              if (i < updates.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// The colors and icon of one tone.
class _ToneStyle {
  const _ToneStyle({
    required this.background,
    required this.border,
    required this.iconColor,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color iconColor;
  final IconData icon;
}

_ToneStyle _styleFor(UpdateTone tone) {
  switch (tone) {
    case UpdateTone.alert:
      return _ToneStyle(
        background: AppColors.missed.withValues(alpha: 0.10),
        border: AppColors.missed.withValues(alpha: 0.35),
        iconColor: AppColors.missedText,
        icon: Icons.error_outline_rounded,
      );
    case UpdateTone.info:
      return const _ToneStyle(
        background: AppColors.buttercreamSoft,
        border: AppColors.buttercream,
        iconColor: AppColors.textPrimary,
        icon: Icons.info_outline_rounded,
      );
    case UpdateTone.success:
      return _ToneStyle(
        background: AppColors.oliveGroveSoft,
        border: AppColors.done.withValues(alpha: 0.5),
        iconColor: AppColors.doneText,
        icon: Icons.check_circle_outline_rounded,
      );
  }
}

class _UpdateRow extends StatelessWidget {
  const _UpdateRow({required this.update, required this.onTap});

  final HubUpdate update;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(update.tone);
    final tappable = update.target != UpdateTarget.none;

    return Material(
      color: style.background,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: style.border),
      ),
      child: InkWell(
        onTap: tappable ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(style.icon, size: 22, color: style.iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  update.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (tappable)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}