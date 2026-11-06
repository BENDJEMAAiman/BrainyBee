
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_project/BrainyBee/quiz/business_logic/quiz_cubit.dart';
import 'package:mobile_app_project/BrainyBee/quiz/business_logic/quiz_state.dart';
import 'package:mobile_app_project/BrainyBee/quiz/data/quiz_repository.dart';
import 'package:mobile_app_project/BrainyBee/quiz/data/quiz_web_service.dart';
import 'package:mobile_app_project/BrainyBee/quiz/model/quiz_model.dart';
import 'package:mobile_app_project/core/dependecy_injection/repositories.dart';
import 'package:mobile_app_project/core/network/dio_client.dart';



class QuizApiTestScreen extends StatefulWidget {
  const QuizApiTestScreen({super.key});

  @override
  State<QuizApiTestScreen> createState() => _QuizApiTestScreenState();
}

class _QuizApiTestScreenState extends State<QuizApiTestScreen> {
  late Future<Map<String, dynamic>> _categoriesFuture;

  // Store the selected answer index for each displayed question.
  final Map<int, int> _selectedAnswers = {};

  @override
void initState() {
  super.initState();
  _categoriesFuture = Repositories.quizRepository.getCategories();
}

  void _refreshCategories() {
    setState(() {
      _categoriesFuture = QuizRepositoryCategories.get();
    });
  }

  void _loadQuestions() {
    setState(() {
      _selectedAnswers.clear();
    });

    context.read<QuizCubit>().loadQuestions(
          difficulty: 'EASY',
          limit: 10,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BrainyBee API Test'),
        actions: [
          IconButton(
            tooltip: 'Refresh categories',
            onPressed: _refreshCategories,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.bubble_chart,
                  size: 38,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  'Explore and learn!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Testing real content from QuizAPI.io.',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadQuestions,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Load 10 easy questions'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Available topics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _buildCategories(),
          const SizedBox(height: 24),
          Text(
            'Quiz questions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildQuestions(),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _errorCard(
            'Could not load categories: ${snapshot.error}',
          );
        }

        final response = snapshot.data;
        final rawTopics = response?['data'];

        if (rawTopics is! List || rawTopics.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No topics were returned by the API.'),
            ),
          );
        }

        final topics = rawTopics
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        return Column(
          children: topics.map((topic) {
            final rawCategories = topic['categories'];
            final categories = rawCategories is List
                ? rawCategories
                    .whereType<Map>()
                    .map((item) => Map<String, dynamic>.from(item))
                    .toList()
                : <Map<String, dynamic>>[];

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.menu_book),
                ),
                title: Text(
                  topic['name']?.toString() ?? 'Untitled topic',
                ),
                subtitle: Text(
                  '${categories.length} categories',
                ),
                children: categories.map((category) {
                  final name =
                      category['name']?.toString() ?? 'Unnamed';
                  final count = category['quizCount'] ?? 0;
                  final tags = category['tags'] is List
                      ? (category['tags'] as List)
                          .map((tag) => tag.toString())
                          .take(3)
                          .join(', ')
                      : '';

                  return ListTile(
                    contentPadding: const EdgeInsets.only(
                      left: 32,
                      right: 16,
                    ),
                    leading: const Icon(Icons.category_outlined),
                    title: Text(name),
                    subtitle: Text(
                      '$count published quizzes'
                      '${tags.isEmpty ? '' : '\nTags: $tags'}',
                    ),
                    isThreeLine: tags.isNotEmpty,
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuestions() {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        switch (state.status) {
          case QuizStatus.initial:
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Press "Load 10 easy questions" to test '
                  'authenticated question retrieval.',
                ),
              ),
            );

          case QuizStatus.loading:
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case QuizStatus.failure:
            return _errorCard(
              state.errorMessage ?? 'Unable to load questions.',
              onRetry: _loadQuestions,
            );

          case QuizStatus.success:
            if (state.questions.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'The API returned no usable questions. '
                    'Try another filter or inspect the response.',
                  ),
                ),
              );
            }

            return Column(
              children: List.generate(
                state.questions.length,
                (index) => _buildQuestionCard(
                  state.questions[index],
                  index,
                ),
              ),
            );
        }
      },
    );
  }

  Widget _buildQuestionCard(QuizQuestion question, int index) {
    final colors = Theme.of(context).colorScheme;
    final selectedIndex = _selectedAnswers[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QUESTION ${index + 1}',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.text,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${question.category ?? 'Uncategorized'} • '
              '${question.difficulty}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...List.generate(question.answers.length, (answerIndex) {
              final answer = question.answers[answerIndex];
              final isSelected = selectedIndex == answerIndex;

              Color? backgroundColor;
              IconData? trailingIcon;

              if (selectedIndex != null && isSelected) {
                if (answer.isCorrect) {
                  backgroundColor = Colors.green.shade100;
                  trailingIcon = Icons.check_circle;
                } else {
                  backgroundColor = Colors.red.shade100;
                  trailingIcon = Icons.cancel;
                }
              } else if (selectedIndex != null && answer.isCorrect) {
                backgroundColor = Colors.green.shade50;
                trailingIcon = Icons.check;
              }

              return Card(
                color: backgroundColor,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(answer.text),
                  trailing: trailingIcon == null
                      ? const Icon(Icons.circle_outlined, size: 20)
                      : Icon(trailingIcon),
                  onTap: selectedIndex != null
                      ? null
                      : () {
                          setState(() {
                            _selectedAnswers[index] = answerIndex;
                          });
                        },
                ),
              );
            }),
            if (selectedIndex != null &&
                question.explanation != null &&
                question.explanation!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Explanation: ${question.explanation}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message, {VoidCallback? onRetry}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text(message),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Uses the repository already registered by the app.
class QuizRepositoryCategories {
  static Future<Map<String, dynamic>> get() {
    return QuizCategoriesAccess.repository.getCategories();
  }
}

/// Temporary access point for category retrieval.
/// Replace this with your registered dependency if your setup differs.
class QuizCategoriesAccess {
  static final repository = QuizRepository(
    QuizWebServiceAccess.service,
  );
}

class QuizWebServiceAccess {
  static final service = QuizWebService(
    DioClientAccess.client,
  );
}

class DioClientAccess {
  static final client = DioClient();
}
