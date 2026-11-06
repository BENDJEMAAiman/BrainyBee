
import '../../BrainyBee/quiz/data/quiz_repository.dart';
import '../../BrainyBee/quiz/data/quiz_web_service.dart';
import '../../BrainyBee/quiz/business_logic/quiz_cubit.dart';
import '../network/dio_client.dart';

class Repositories {
  Repositories._();

  static final DioClient dioClient = DioClient();

  static final QuizWebService quizWebService =
      QuizWebService(dioClient);

  static final QuizRepository quizRepository =
      QuizRepository(quizWebService);

  static QuizCubit createQuizCubit() {
    return QuizCubit(quizRepository);
  }
}
