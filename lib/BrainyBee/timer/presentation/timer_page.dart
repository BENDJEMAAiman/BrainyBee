import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_app_project/BrainyBee/timer/business_logic/timer_cubit.dart';
import 'package:mobile_app_project/BrainyBee/timer/business_logic/timer_state.dart';
import 'package:mobile_app_project/BrainyBee/timer/data/timer_repository.dart';
import 'package:mobile_app_project/BrainyBee/timer/model/timer_model.dart';
import 'package:mobile_app_project/BrainyBee/timer/model/timer_target.dart';
import 'package:mobile_app_project/BrainyBee/timer/presentation/timer_screen.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The timer page, fully working. Use THIS widget wherever the page appears
/// (later, in the router).
///
/// It creates the [TimerCubit], gives it the [repository], and connects the
/// Cubit's state to the plain [TimerScreen].
///
/// - [target] is the homework the session is for (null for a quick start).
/// - [onMarkHomeworkDone] is called with the homework's id when the user says
///   it is done. The router will connect it to the Studies page later.
/// - [onExit] is called when the user leaves the page. If a session is still
///   running or paused, the user is asked to confirm first.
/// - [clock] replaces the real clock (used by the preview to speed up time).
class TimerPage extends StatelessWidget {
  const TimerPage({
    super.key,
    required this.repository,
    required this.onMarkHomeworkDone,
    required this.onExit,
    this.target,
    this.clock,
  });

  final TimerRepository repository;
  final TimerTarget? target;
  final void Function(String homeworkId) onMarkHomeworkDone;
  final VoidCallback onExit;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimerCubit>(
      create: (_) => TimerCubit(
        repository: repository,
        target: target,
        now: clock,
      ),
      child: _TimerView(
        target: target,
        onMarkHomeworkDone: onMarkHomeworkDone,
        onExit: onExit,
      ),
    );
  }
}

class _TimerView extends StatefulWidget {
  const _TimerView({
    required this.target,
    required this.onMarkHomeworkDone,
    required this.onExit,
  });

  final TimerTarget? target;
  final void Function(String homeworkId) onMarkHomeworkDone;
  final VoidCallback onExit;

  @override
  State<_TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<_TimerView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// When the app returns from the background, work out the time left right
  /// away (the ticker may have been paused while the app was away).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<TimerCubit>().refresh();
    }
  }

  bool _isActive(TimerState state) {
    final status = state.snapshot.status;
    return status == TimerStatus.running || status == TimerStatus.paused;
  }

  /// Leaves the page. While a session is running or paused, asks first.
  Future<void> _leave(TimerCubit cubit) async {
    if (!_isActive(cubit.state)) {
      widget.onExit();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Stop the timer?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Your session is not finished yet. If you leave now, it will not '
          'be saved.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Keep going'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Leave',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Stopping the timer first makes the page "inactive", so the system back
      // button no longer blocks leaving. Leaving happens after the next frame,
      // once the page has rebuilt with that change.
      cubit.reset();
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onExit());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TimerCubit>();
    final target = widget.target;

    return BlocConsumer<TimerCubit, TimerState>(
      // Show a message only for the state that carries an error.
      listenWhen: (previous, current) => current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        return PopScope(
          // While a session is running or paused, the system back button asks
          // for confirmation instead of leaving.
          canPop: !_isActive(state),
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _leave(cubit);
          },
          child: TimerScreen(
            snapshot: state.snapshot,
            homeworkTitle: target?.title,
            homeworkSubject: target?.subject,
            homeworkMarkedDone: state.homeworkMarkedDone,
            onSelectMinutes: cubit.selectMinutes,
            onStart: cubit.start,
            onPause: cubit.pause,
            onResume: cubit.resume,
            onReset: cubit.reset,
            onStartBreak: cubit.startBreak,
            onMarkHomeworkDone: () {
              final homeworkId = target?.homeworkId;
              if (homeworkId == null) return;
              widget.onMarkHomeworkDone(homeworkId);
              cubit.homeworkMarkedDone();
            },
            onFinish: () => _leave(cubit),
          ),
        );
      },
    );
  }
}