import 'package:go_router/go_router.dart';

import 'package:mobile_app_project/BrainyBee/habits/data/habit_repository.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/habits_page.dart';
import 'package:mobile_app_project/BrainyBee/hub/presentation/hub_page.dart';
import 'package:mobile_app_project/BrainyBee/studies/business_logic/homework_actions.dart';
import 'package:mobile_app_project/BrainyBee/studies/data/studies_respository.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/studies_page.dart';
import 'package:mobile_app_project/BrainyBee/timer/data/timer_repository.dart';
import 'package:mobile_app_project/BrainyBee/timer/model/timer_target.dart';
import 'package:mobile_app_project/BrainyBee/timer/presentation/timer_page.dart';
import 'package:mobile_app_project/app/app_shell.dart';

/// All the routes of the app.
///
///   /          Home (the hub)      tab 1 of the bottom bar
///   /habits    Habits              tab 2
///   /studies   Studies             tab 3
///   /timer     Focus timer         full screen, opened from the hub or from a
///                                  homework (not a tab)
///
/// The three repositories are created once at startup and handed in here, so
/// every page works on the same data.
GoRouter createAppRouter({
  required HabitRepository habitRepository,
  required StudiesRepository studiesRepository,
  required TimerRepository timerRepository,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // The three tabs share the bottom navigation bar.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return HubPage(
                    habitRepository: habitRepository,
                    studiesRepository: studiesRepository,
                    // Going to another tab's location switches to that tab.
                    onOpenHabits: () => context.go('/habits'),
                    onOpenStudies: () => context.go('/studies'),
                    // A quick start: no homework attached.
                    onStartFocus: () => context.push('/timer'),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) {
                  return HabitsPage(repository: habitRepository);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/studies',
                builder: (context, state) {
                  return StudiesPage(
                    repository: studiesRepository,
                    onStartTimer: (homework) {
                      context.push(
                        '/timer',
                        extra: TimerTarget(
                          homeworkId: homework.id,
                          title: homework.title,
                          subject: homework.subject,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // The timer is outside the tabs, so it opens full screen (no bottom bar).
      GoRoute(
        path: '/timer',
        builder: (context, state) {
          final target = state.extra is TimerTarget
              ? state.extra as TimerTarget
              : null;

          return TimerPage(
            repository: timerRepository,
            target: target,
            onMarkHomeworkDone: (homeworkId) {
              HomeworkActions.markDone(studiesRepository, homeworkId);
            },
            onExit: () => context.pop(),
          );
        },
      ),
    ],
  );
}
