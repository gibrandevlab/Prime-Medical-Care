import 'package:dio/dio.dart';
import '../helpers/api_client.dart';

class ScheduleService {
  final Dio _dio = dioClient;

  Future<Map<String, dynamic>> getSchedules(int dokterId) async {
    try {
      final resp = await _dio.get('/schedule/$dokterId');
      return resp.data as Map<String, dynamic>;
    } catch (e) {
      print('ScheduleService.getSchedules error: $e');
      return {'base': [], 'overrides': []};
    }
  }

  // Get overrides for a specific doctor
  Future<List<dynamic>> getOverrides(int dokterId) async {
    try {
      final resp = await _dio.get('/schedule/$dokterId');
      final data = resp.data as Map<String, dynamic>;
      return (data['overrides'] ?? []) as List<dynamic>;
    } catch (e) {
      print('ScheduleService.getOverrides error: $e');
      return [];
    }
  }

  Future<bool> addOverride({
    required int dokterId,
    required String startDate,
    String? endDate,
    required bool isAvailable,
    String? note,
  }) async {
    try {
      await _dio.post('/schedule/override', data: {
        'dokterId': dokterId,
        'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        'isAvailable': isAvailable,
        if (note != null) 'note': note,
      });
      return true;
    } catch (e) {
      print('ScheduleService.addOverride error: $e');
      return false;
    }
  }

  Future<bool> deleteOverride(int id) async {
    try {
      await _dio.delete('/schedule/override/$id');
      return true;
    } catch (e) {
      print('ScheduleService.deleteOverride error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> requestOverride({
    required int dokterId,
    required String startDate,
    String? endDate,
    required bool isAvailable,
    String? note,
    int? substituteDokterId,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final resp = await _dio.post('/schedule/request-override', data: {
        'dokterId': dokterId,
        'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        'isAvailable': isAvailable,
        if (note != null) 'note': note,
        if (substituteDokterId != null) 'substituteDokterId': substituteDokterId,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
      });
      return resp.data as Map<String, dynamic>;
    } catch (e) {
      print('ScheduleService.requestOverride error: $e');
      return {'error': e.toString()};
    }
  }

  Future<bool> approveOverride(int id, bool approved, int adminId) async {
    try {
      await _dio.put('/schedule/approve-override/$id', data: {
        'approved': approved,
        'adminId': adminId,
      });
      return true;
    } catch (e) {
      print('ScheduleService.approveOverride error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getAvailableSubstitutes(int dokterId, String date) async {
    try {
      final resp = await _dio.get('/schedule/available-substitutes', queryParameters: {
        'dokterId': dokterId,
        'date': date,
      });
      return (resp.data['availableDoctors'] ?? []) as List<dynamic>;
    } catch (e) {
      print('ScheduleService.getAvailableSubstitutes error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getPendingRequests() async {
    try {
      final resp = await _dio.get('/schedule/pending-requests');
      return (resp.data['requests'] ?? []) as List<dynamic>;
    } catch (e) {
      print('ScheduleService.getPendingRequests error: $e');
      return [];
    }
  }
}
