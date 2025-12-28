import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/pasien.dart';

class PasienService {
  final Dio _dio = dioClient;

  Future<List<Pasien>> getAll() async {
    try {
      final resp = await _dio.get('/pasien');
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => Pasien.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('PasienService.getAll error: ${e.message}');
      return [];
    } catch (e) {
      print('PasienService.getAll unexpected: $e');
      return [];
    }
  }

  Future<Pasien?> getById(int id) async {
    try {
      final resp = await _dio.get('/pasien/$id');
      final data = resp.data;
      if (data is Map<String, dynamic>) return Pasien.fromJson(data);
      if (data is Map) return Pasien.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      print('PasienService.getById error: ${e.message}');
      return null;
    } catch (e) {
      print('PasienService.getById unexpected: $e');
      return null;
    }
  }

  Future<Pasien?> add(Pasien p) async {
    try {
      final resp = await _dio.post('/pasien', data: p.toJson());
      final data = resp.data;
      if (data is Map<String, dynamic>) return Pasien.fromJson(data);
      if (data is Map) return Pasien.fromJson(Map<String, dynamic>.from(data));
      throw Exception('Respon server tidak valid');
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = data?['message'] ?? e.message;
      if (data?['details'] is List) {
        final details = (data['details'] as List).map((err) => "${err['path']}: ${err['msg']}").join(', ');
        msg += " ($details)";
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception('Gagal mendaftar pasien: $e');
    }
  }

  Future<Pasien?> update(Pasien p, int id) async {
    try {
      final resp = await _dio.put('/pasien/$id', data: p.toJson());
      final data = resp.data;
      if (data is Map<String, dynamic>) return Pasien.fromJson(data);
      if (data is Map) return Pasien.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      print('PasienService.update error: ${e.message}');
      return null;
    } catch (e) {
      print('PasienService.update unexpected: $e');
      return null;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('/pasien/$id');
      return true;
    } on DioException catch (e) {
      print('PasienService.delete error: ${e.message}');
      return false;
    } catch (e) {
      print('PasienService.delete unexpected: $e');
      return false;
    }
  }
}
