
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/quiz_repository.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this._repository) : super(const QuizState());

  final QuizRepository _repository;

  Future<void> loadQuestions({
    String? category,
    String? difficulty,
    int limit = 10,
    int offset = 0,
  }) async {
    emit(state.copyWith(status: QuizStatus.loading));

    try {
      final questions = await _repository.getQuestions(
        category: category,
        difficulty: difficulty,
        limit: limit,
        offset: offset,
      );

      emit(
        QuizState(
          status: QuizStatus.success,
          questions: questions,
        ),
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;

      final message = switch (statusCode) {
        401 => 'QuizAPI authentication failed. Check your API key.',
        403 => 'QuizAPI denied access to this resource.',
        429 => 'Too many requests. Please try again later.',
        _ => error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout
            ? 'The request timed out. Check your connection.'
            : 'Could not load quizzes. Check your connection and try again.',
      };

      emit(
        QuizState(
          status: QuizStatus.failure,
          errorMessage: message,
        ),
      );
    } on FormatException catch (error) {
      emit(
        QuizState(
          status: QuizStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        const QuizState(
          status: QuizStatus.failure,
          errorMessage: 'An unexpected error occurred.',
        ),
      );
    }
  }
}
