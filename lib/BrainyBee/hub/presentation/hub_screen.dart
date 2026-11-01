import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/hub/model/hub_stats.dart';
import 'package:mobile_app_project/BrainyBee/hub/model/hub_summary.dart';
import 'package:mobile_app_project/BrainyBee/hub/model/hub_updates.dart';
import 'package:mobile_app_project/BrainyBee/hub/presentation/widgets/hub_cards.dart';
import 'package:mobile_app_project/BrainyBee/hub/presentation/widgets/hub_stats_card.dart';
import 'package:mobile_app_project/BrainyBee/hub/presentation/widgets/hub_updates_card.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

const List<String> _weekdayNames = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// The main page: today's date, the latest updates, three cards (Habits,
/// Studies, Focus timer) and the weekly statistics.
///
/// This screen owns NO data and changes nothing. It draws what it receives and
/// reports taps through the callbacks. For now a preview file supplies dummy
/// data; later a Cubit will supply the real data, and the router will handle
/// the callbacks by opening the other pages.
class HubScreen extends StatelessWidget {
  const HubScreen({
    super.key,
    required this.summary,
    required this.updates,
    required this.stats,
    required this.now,
    required this.onOpenHabits,
    required this.onOpenStudies,
    required this.onStartFocus,
  });

  final HubSummary summary;
  final List<HubUpdate> updates;
  final HubStats stats;
  final DateTime now;

  /// The user tapped the Habits card (or a habits update).
  final VoidCallback onOpenHabits;

  /// The user tapped the Studies card (or a homework update).
  final VoidCallback onOpenStudies;

  /// The user pressed "Start focus" (a timer with no homework attached).
  final VoidCallback onStartFocus;

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${_weekdayNames[now.weekday % 7]}, ${now.day} '
        '${_monthNames[now.month - 1]}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Keeps the layout tidy on wide screens (e.g. Chrome).
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              children: [
                // ---- Header ----
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Latest updates ----
                LatestUpdatesCard(
                  updates: updates,
                  onOpenHabits: onOpenHabits,
                  onOpenStudies: onOpenStudies,
                ),
                const SizedBox(height: 16),

                // ---- Cards ----
                HabitsHubCard(
                  done: summary.habitsDone,
                  total: summary.habitsTotal,
                  onTap: onOpenHabits,
                ),
                const SizedBox(height: 16),
                StudiesHubCard(
                  upcomingClass: summary.upcomingClass,
                  homeworkDueToday: summary.homeworkDueToday,
                  onTap: onOpenStudies,
                ),
                const SizedBox(height: 16),
                FocusHubCard(onStart: onStartFocus),

                // ---- Statistics (only when there is something to show) ----
                if (stats.hasAny) ...[
                  const SizedBox(height: 16),
                  HubStatsCard(stats: stats),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}