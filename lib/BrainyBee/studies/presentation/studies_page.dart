import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_app_project/BrainyBee/studies/business_logic/studies_cubit.dart';
import 'package:mobile_app_project/BrainyBee/studies/business_logic/studies_state.dart';
import 'package:mobile_app_project/BrainyBee/studies/data/studies_respository.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/presentation/studies_screen.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The Studies page, fully working. Use THIS widget wherever the page appears
/// (later, in the router).
///
/// It creates the [StudiesCubit], gives it the [repository], and connects the
/// Cubit's state to the plain [StudiesScreen].
///
/// [onStartTimer] is called when the user taps the timer button of a homework.
/// Opening the timer page is not this page's job: the router will provide it.
class StudiesPage extends StatelessWidget {
  const StudiesPage({
    super.key,
    required this.repository,
    required this.onStartTimer,
  });

  final StudiesRepository repository;
  final void Function(Homework homework) onStartTimer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StudiesCubit>(
      create: (_) => StudiesCubit(repository: repository)..start(),
      child: _StudiesView(onStartTimer: onStartTimer),
    );
  }
}

class _StudiesView extends StatefulWidget {
  const _StudiesView({required this.onStartTimer});

  final void Function(Homework homework) onStartTimer;

  @override
  State<_StudiesView> createState() => _StudiesViewState();
}

class _StudiesViewState extends State<_StudiesView>
    with WidgetsBindingObserver {
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
      context.read<StudiesCubit>().refreshNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StudiesCubit>();

    return BlocConsumer<StudiesCubit, StudiesState>(
      // Show a message only for the state that carries an error.
      listenWhen: (previous, current) => current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        switch (state.status) {
          case StudiesStatus.loading:
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );

          case StudiesStatus.failure:
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Could not load your studies.',
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

          case StudiesStatus.ready:
            return StudiesScreen(
              timetable: state.timetable,
              homeworks: state.homeworks,
              now: state.now,
              onTimetableCellChanged: cubit.setTimetableCell,
              onAddHomework: (data) => cubit.addHomework(
                title: data.title,
                subject: data.subject,
                dueDate: data.dueDate,
              ),
              onEditHomework: (homework, data) => cubit.editHomework(
                homework.id,
                title: data.title,
                subject: data.subject,
                dueDate: data.dueDate,
              ),
              onDeleteHomework: (homework) => cubit.deleteHomework(homework.id),
              onToggleHomework: (homework) => cubit.toggleHomework(homework.id),
              onStartTimer: widget.onStartTimer,
            );
        }
      },
    );
  }
}