import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_app_project/BrainyBee/habits/data/habit_repository.dart';
import 'package:mobile_app_project/BrainyBee/hub/business_logic/hub_cubit.dart';
import 'package:mobile_app_project/BrainyBee/hub/business_logic/hub_state.dart';
import 'package:mobile_app_project/BrainyBee/hub/presentation/hub_screen.dart';
import 'package:mobile_app_project/BrainyBee/studies/data/studies_respository.dart';

import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The hub page, fully working. Use THIS widget wherever the page appears.
///
/// It creates the [HubCubit], gives it the two repositories it reads from, and
/// connects the Cubit's state to the plain [HubScreen]. The three callbacks say
/// where each card leads; the router provides them.
class HubPage extends StatelessWidget {
  const HubPage({
    super.key,
    required this.habitRepository,
    required this.studiesRepository,
    required this.onOpenHabits,
    required this.onOpenStudies,
    required this.onStartFocus,
  });

  final HabitRepository habitRepository;
  final StudiesRepository studiesRepository;
  final VoidCallback onOpenHabits;
  final VoidCallback onOpenStudies;
  final VoidCallback onStartFocus;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HubCubit>(
      create: (_) => HubCubit(
        habitRepository: habitRepository,
        studiesRepository: studiesRepository,
      )..start(),
      child: _HubView(
        onOpenHabits: onOpenHabits,
        onOpenStudies: onOpenStudies,
        onStartFocus: onStartFocus,
      ),
    );
  }
}

class _HubView extends StatefulWidget {
  const _HubView({
    required this.onOpenHabits,
    required this.onOpenStudies,
    required this.onStartFocus,
  });

  final VoidCallback onOpenHabits;
  final VoidCallback onOpenStudies;
  final VoidCallback onStartFocus;

  @override
  State<_HubView> createState() => _HubViewState();
}

class _HubViewState extends State<_HubView> with WidgetsBindingObserver {
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

  /// When the app returns from the background, the time may have moved on.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HubCubit>().refreshNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HubCubit>();

    return BlocBuilder<HubCubit, HubState>(
      builder: (context, state) {
        switch (state.status) {
          case HubStatus.loading:
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );

          case HubStatus.failure:
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Could not load your day.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: cubit.start,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                      ),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );

          case HubStatus.ready:
            return HubScreen(
              summary: state.summary,
              updates: state.updates,
              stats: state.stats,
              now: state.now,
              onOpenHabits: widget.onOpenHabits,
              onOpenStudies: widget.onOpenStudies,
              onStartFocus: widget.onStartFocus,
            );
        }
      },
    );
  }
}