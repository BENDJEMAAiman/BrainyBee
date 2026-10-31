import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_app_project/BrainyBee/habits/business_logic/habit_cubit.dart';
import 'package:mobile_app_project/BrainyBee/habits/business_logic/habit_state.dart';
import 'package:mobile_app_project/BrainyBee/habits/data/habit_repository.dart';
import 'package:mobile_app_project/BrainyBee/habits/presentation/habits_screen.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The Habits page, fully working. Use THIS widget wherever the page appears
/// (later, in the router).
///
/// It creates the [HabitCubit], gives it the [repository], and connects the
/// Cubit's state to the plain [HabitsScreen].
class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key, required this.repository});

  final HabitRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HabitCubit>(
      create: (_) => HabitCubit(repository: repository)..start(),
      child: const _HabitsView(),
    );
  }
}

class _HabitsView extends StatefulWidget {
  const _HabitsView();

  @override
  State<_HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends State<_HabitsView> with WidgetsBindingObserver {
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

  /// When the app returns from the background, the date may have changed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HabitCubit>().refreshToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HabitCubit>();

    return BlocConsumer<HabitCubit, HabitState>(
      // Show a message only for the state that carries an error.
      listenWhen: (previous, current) => current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        switch (state.status) {
          case HabitStatus.loading:
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );

          case HabitStatus.failure:
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Could not load your habits.',
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

          case HabitStatus.ready:
            return HabitsScreen(
              habits: state.habits,
              today: state.today,
              onDayToggled: (habit, day, done) =>
                  cubit.toggleDay(habit.id, day, done),
              onNewCycle: (habit) => cubit.startNewCycle(habit.id),
              onAddHabit: cubit.addHabit,
              onEditHabit: (habit, name, iconKey) =>
                  cubit.editHabit(habit.id, name, iconKey),
              onDeleteHabit: (habit) => cubit.deleteHabit(habit.id),
            );
        }
      },
    );
  }
}