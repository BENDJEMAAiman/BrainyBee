import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/timer/data/local_timer_repository.dart';
import 'package:mobile_app_project/BrainyBee/timer/data/timer_repository.dart';
import 'package:mobile_app_project/BrainyBee/timer/model/focus_session_model.dart';
import 'package:mobile_app_project/BrainyBee/timer/model/timer_target.dart';
import 'package:mobile_app_project/BrainyBee/timer/presentation/timer_page.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// TEMPORARY file: delete it when the timer is connected to the router.
/// Run it with:  flutter run -t lib/timer_preview.dart -d chrome --web-port 5000

/// How fast time passes in this preview.
///  1  = real speed.
///  60 = test speed: 1 real second counts as 1 minute, so a 25 minute session
///       finishes in about 25 seconds.
/// Change it, then restart the app.
const int _testSpeed = 1;

/// The homework the timer is opened for. Set it to null to see the quick-start
/// version (no homework).
const TimerTarget? _target = TimerTarget(
  homeworkId: 'demo-homework',
  title: 'Exercises 4 to 7, page 52',
  subject: 'Math',
);

/// The moment the preview started, used to build the fast clock.
final DateTime _anchor = DateTime.now();

/// A clock that runs [_testSpeed] times faster than the real one.
DateTime _fastNow() {
  final elapsed = DateTime.now().difference(_anchor);
  return _anchor.add(elapsed * _testSpeed);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await LocalTimerRepository.create();
  runApp(_PreviewApp(repository: repository));
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp({required this.repository});

  final TimerRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          void say(String message) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }

          return Stack(
            children: [
              TimerPage(
                repository: repository,
                target: _target,
                clock: _testSpeed == 1 ? null : _fastNow,
                onMarkHomeworkDone: (homeworkId) =>
                    say('Homework "$homeworkId" would be marked as done.'),
                onExit: () => say('The timer page would close here.'),
              ),

              // Preview-only counter of the saved sessions (it will not exist
              // in the real app).
              Positioned(
                left: 16,
                bottom: 16,
                child: SafeArea(
                  child: StreamBuilder<List<FocusSession>>(
                    stream: repository.watchSessions(),
                    builder: (context, snapshot) {
                      final sessions = snapshot.data ?? const <FocusSession>[];
                      final minutes = sessions.fold<int>(
                        0,
                        (sum, session) => sum + session.minutes,
                      );
                      return Material(
                        color: AppColors.surface,
                        shape: StadiumBorder(
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Text(
                            'Saved sessions: ${sessions.length} · $minutes min',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}