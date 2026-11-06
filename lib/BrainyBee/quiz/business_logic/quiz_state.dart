
import '../model/quiz_model.dart';

enum QuizStatus {
  initial,
  loading,
  success,
  failure,
}

class QuizState {
  const QuizState({
    this.status = QuizStatus.initial,
    this.questions = const [],
    this.errorMessage,
  });

  final QuizStatus status;
  final List<QuizQuestion> questions;
  final String? errorMessage;

  QuizState copyWith({
    QuizStatus? status,
    List<QuizQuestion>? questions,
    String? errorMessage,
  }) {
    return QuizState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      errorMessage: errorMessage,
    );
  }
}
