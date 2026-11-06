
import '../model/quiz_model.dart';
import 'quiz_web_service.dart';

class QuizRepository {
  QuizRepository(this._webService);

  final QuizWebService _webService;

  Future<List<QuizQuestion>> getQuestions({
    String? category,
    String? difficulty,
    int limit = 10,
    int offset = 0,
  }) {
    return _webService.fetchQuestions(
      category: category,
      difficulty: difficulty,
      type: 'MULTIPLE_CHOICE,TRUE_FALSE',
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>> getCategories() {
    return _webService.fetchCategories();
  }
}
