import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/antrian.dart';

class AntrianService {
  final Dio _dio = dioClient;

  Future<List<AntrianModel>> getAll({String? status}) async {
    try {
      final resp = await _dio.get(
        '/antrian',
        queryParameters: {if (status != null) 'status': status},
      );
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => AntrianModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil data antrian: $e');
    }
  }

  // Alias for getAll (for backward compatibility)
  Future<List<AntrianModel>> getAntrian({String? status}) async {
    return getAll(status: status);
  }

  Future<AntrianModel> create(Map<String, dynamic> payload) async {
    try {
      final resp = await _dio.post('/antrian', data: payload);
      final data = resp.data;
      if (data is Map<String, dynamic>) return AntrianModel.fromJson(data);
      throw Exception('Respon server tidak valid');
    } catch (e) {
      if (e is DioException) {
         final msg = e.response?.data['message'] ?? e.message;
         throw Exception(msg);
      }
      throw Exception('Gagal membuat antrian: $e');
    }
  }

  Future<List<AntrianModel>> getByDokter(int dokterId, {String? status}) async {
    try {
      final resp = await _dio.get(
        '/antrian/dokter/$dokterId',
        queryParameters: {if (status != null) 'status': status},
      );
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => AntrianModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('AntrianService.getByDokter error: $e');
      return [];
    }
  }

  Future<bool> updateStatus(int id, String status) async {
    try {
      await _dio.put('/antrian/$id/status', data: {'status': status});
      return true;
    } catch (e) {
      print('AntrianService.updateStatus error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> checkSlot(int dokterId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final resp = await _dio.get('/antrian/check-slot', queryParameters: {
        'dokterId': dokterId,
        'date': dateStr
      });
      return resp.data as Map<String, dynamic>;
    } catch (e) {
      print('AntrianService.checkSlot error: $e');
      return {'available': false, 'note': 'Gagal mengecek jadwal'};
    }
  }
}
