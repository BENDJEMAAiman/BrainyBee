
import 'package:mobile_app_project/BrainyBee/studies/data/studies_respository.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';

/// Small actions on homework that can be used from outside the Studies page
/// (for example by the timer page).
class HomeworkActions {
  HomeworkActions._();

  /// Marks the homework as done today.
  ///
  /// Unlike ticking in the list (which toggles), this can be called twice
  /// without undoing anything: a homework that is already done is left alone.
  static Future<void> markDone(
    StudiesRepository repository,
    String homeworkId, {
    DateTime? now,
  }) async {
    final homeworks = await repository.watchHomeworks().first;

    for (final homework in homeworks) {
      if (homework.id != homeworkId) continue;
      if (homework.isCompleted) return;

      await repository.saveHomework(
        homework.withCompleted(
          done: true,
          today: Homework.dateOnly(now ?? DateTime.now()),
        ),
      );
      return;
    }
  }
}