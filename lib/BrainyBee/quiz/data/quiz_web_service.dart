
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../model/quiz_model.dart';

class QuizWebService {
  QuizWebService(this._client);

  final DioClient _client;

  /// Public endpoint: no API key is required by the documentation.
  Future<Map<String, dynamic>> fetchCategories() async {
    final response = await _client.dio.get('/categories');

    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Protected endpoint: requires a valid QuizAPI key.
  Future<List<QuizQuestion>> fetchQuestions({
    String? category,
    String? difficulty,
    String? type,
    int limit = 10,
    int offset = 0,
    bool random = true,
  }) async {
    final response = await _client.dio.get(
      '/questions',
      queryParameters: {
        if (category != null) 'category': category,
        if (difficulty != null) 'difficulty': difficulty,
        if (type != null) 'type': type,
        'limit': limit.clamp(1, 50),
        'offset': offset < 0 ? 0 : offset,
        'random': random.toString(),
      },
    );

    final body = Map<String, dynamic>.from(response.data as Map);
    final data = body['data'];

    if (body['success'] != true || data is! List) {
      throw const FormatException(
        'QuizAPI returned an unexpected question response.',
      );
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(QuizQuestion.fromJson)
        .where((question) =>
            question.text.isNotEmpty &&
            question.answers.length >= 2 &&
            question.answers.any((answer) => answer.isCorrect))
        .toList();
  }
}
