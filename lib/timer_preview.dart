import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/timer/model/timer_model.dart';
import 'package:mobile_app_project/BrainyBee/timer/presentation/timer_screen.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// TEMPORARY file: delete it when the real timer logic is connected.
/// Run it with:  flutter run -t lib/timer_preview.dart -d chrome --web-port 5000

/// The homework the timer is opened for. Set both to null to see the version
/// without a homework (like a quick start from the main page).
const String? _homeworkTitle = 'Exercises 4 to 7, page 52';
const String? _homeworkSubject = 'Math';

/// How many timer seconds pass per real second.
/// 1 = real speed. 60 = "fast test": 1 real second counts as 1 minute.
const int _realSpeed = 1;
const int _fastSpeed = 60;

void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _PreviewPage(),
    );
  }
}

class _PreviewPage extends StatefulWidget {
  const _PreviewPage();

  @override
  State<_PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<_PreviewPage> {
  TimerSnapshot _snapshot = TimerSnapshot.idle();
  Timer? _ticker;

  /// The focus length to go back to after a reset or a break.
  int _focusMinutes = TimerPresets.defaultMinutes;

  /// Timer seconds that pass per real second (see the constants at the top).
  int _secondsPerTick = _realSpeed;

  bool get _isFast => _secondsPerTick == _fastSpeed;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _select(int minutes) {
    setState(() {
      _focusMinutes = minutes;
      _snapshot = TimerSnapshot.idle(minutes: minutes);
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final remaining = _snapshot.remainingSeconds - _secondsPerTick;
    if (remaining <= 0) {
      _ticker?.cancel();
      setState(() {
        _snapshot = _snapshot.copyWith(
          remainingSeconds: 0,
          status: TimerStatus.finished,
        );
      });
    } else {
      setState(() {
        _snapshot = _snapshot.copyWith(remainingSeconds: remaining);
      });
    }
  }

  void _start() {
    setState(() {
      _snapshot = _snapshot.copyWith(status: TimerStatus.running);
    });
    _startTicker();
  }

  void _pause() {
    _ticker?.cancel();
    setState(() {
      _snapshot = _snapshot.copyWith(status: TimerStatus.paused);
    });
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _snapshot = TimerSnapshot.idle(minutes: _focusMinutes);
    });
  }

  void _startBreak() {
    const seconds = TimerPresets.breakMinutes * 60;
    setState(() {
      _snapshot = const TimerSnapshot(
        phase: TimerPhase.rest,
        status: TimerStatus.running,
        totalSeconds: seconds,
        remainingSeconds: seconds,
      );
    });
    _startTicker();
  }

  void _toggleSpeed() {
    setState(() {
      _secondsPerTick = _isFast ? _realSpeed : _fastSpeed;
    });
  }

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TimerScreen(
          snapshot: _snapshot,
          homeworkTitle: _homeworkTitle,
          homeworkSubject: _homeworkSubject,
          onSelectMinutes: _select,
          onStart: _start,
          onPause: _pause,
          onResume: _start,
          onReset: _reset,
          onStartBreak: _startBreak,
          onMarkHomeworkDone: () =>
              _say('The homework would be marked as done.'),
          onFinish: () => _say('The timer page would close here.'),
        ),

        // Preview-only switch (it will not exist in the real app).
        Positioned(
          left: 16,
          bottom: 16,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: FilterChip(
                label: Text(
                  _isFast ? 'Test speed: 1 sec = 1 min' : 'Real speed',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                avatar: const Icon(Icons.speed_rounded, size: 18),
                selected: _isFast,
                onSelected: (_) => _toggleSpeed(),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.canyonSoft,
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
      ],
    );
  }
}