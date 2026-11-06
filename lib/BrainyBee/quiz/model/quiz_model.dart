
class QuizAnswer {
  const QuizAnswer({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  final String id;
  final String text;
  final bool isCorrect;

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isCorrect: json['isCorrect'] == true,
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.difficulty,
    required this.category,
    required this.explanation,
    required this.answers,
  });

  final String id;
  final String text;
  final String type;
  final String difficulty;
  final String? category;
  final String? explanation;
  final List<QuizAnswer> answers;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];

    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      type: json['type']?.toString() ?? 'MULTIPLE_CHOICE',
      difficulty: json['difficulty']?.toString() ?? 'EASY',
      category: json['category']?.toString(),
      explanation: json['explanation']?.toString(),
      answers: rawAnswers is List
          ? rawAnswers
              .whereType<Map<String, dynamic>>()
              .map(QuizAnswer.fromJson)
              .toList()
          : const [],
    );
  }
}
