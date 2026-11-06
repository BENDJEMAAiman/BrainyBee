
import 'package:dio/dio.dart';

class DioClient {
  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://quizapi.io/api/v1',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    final apiKey = const String.fromEnvironment('QUIZAPI_KEY');

    if (apiKey.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $apiKey';
    }
  }

  final Dio dio;
}
