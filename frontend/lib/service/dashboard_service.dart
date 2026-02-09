import 'package:dio/dio.dart';
import '../helpers/api_client.dart';

class DashboardService {
  final Dio _dio = dioClient;

  Future<Map<String, dynamic>> getStats(String role, String? userId) async {
    try {
      final resp = await _dio.get(
        '/dashboard/stats',
        queryParameters: {
          'role': role,
          if (userId != null) 'userId': userId,
        },
      );
      
      if (resp.data is Map<String, dynamic>) {
        return resp.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      // Log error but don't crash UI, return empty map
      print('DashboardService error: $e');
      return {};
    }
  }
}
