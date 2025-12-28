import 'package:dio/dio.dart';
import '../helpers/api_client.dart';

class DashboardService {
  final Dio _dio = dioClient;

  Future<Map<String, dynamic>> getStats(String role, String? userId) async {
    try {
      final resp = await _dio.get('/dashboard/stats', queryParameters: {
        'role': role,
        if (userId != null) 'userId': userId,
      });
      return resp.data as Map<String, dynamic>;
    } catch (e) {
      print('DashboardService.getStats error: $e');
      return {};
    }
  }
}
