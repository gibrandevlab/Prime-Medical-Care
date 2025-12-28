import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.137.1:3000',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            // ignore errors retrieving token
          }
          return handler.next(options);
        },
        onError: (err, handler) {
          try {
            final status = err.response?.statusCode;
            final msg = err.message;
            final body = err.response?.data;
            print('ApiClient error: $status $msg');
            if (body != null) print('ApiClient response body: $body');
          } catch (_) {}
          return handler.next(err);
        },
      ),
    );
  }
}

/// Exported Dio instance for use in services
final Dio dioClient = ApiClient().dio;
