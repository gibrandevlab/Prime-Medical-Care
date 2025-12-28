import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/dokter.dart';

class DokterService {
  final Dio _dio = dioClient;

  Future<List<Dokter>> getAll() async {
    try {
      final resp = await _dio.get('/dokter');
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => Dokter.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('DokterService.getAll error: ${e.message}');
      return [];
    } catch (e) {
      print('DokterService.getAll unexpected: $e');
      return [];
    }
  }

  Future<Dokter?> getById(int id) async {
    try {
      final resp = await _dio.get('/dokter/$id');
      final data = resp.data;
      if (data is Map<String, dynamic>) return Dokter.fromJson(data);
      if (data is Map) return Dokter.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      print('DokterService.getById error: ${e.message}');
      return null;
    } catch (e) {
      print('DokterService.getById unexpected: $e');
      return null;
    }
  }

  Future<Dokter?> add(Dokter d) async {
    try {
      final resp = await _dio.post('/dokter', data: d.toJson());
      final data = resp.data;
      if (data is Map<String, dynamic>) return Dokter.fromJson(data);
      if (data is Map) return Dokter.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      print('DokterService.add error: ${e.message}');
      return null;
    } catch (e) {
      print('DokterService.add unexpected: $e');
      return null;
    }
  }

  Future<Dokter?> update(Dokter d, int id) async {
    try {
      final resp = await _dio.put('/dokter/$id', data: d.toJson());
      final data = resp.data;
      if (data is Map<String, dynamic>) return Dokter.fromJson(data);
      if (data is Map) return Dokter.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      print('DokterService.update error: ${e.message}');
      return null;
    } catch (e) {
      print('DokterService.update unexpected: $e');
      return null;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('/dokter/$id');
      return true;
    } on DioException catch (e) {
      print('DokterService.delete error: ${e.message}');
      return false;
    } catch (e) {
      print('DokterService.delete unexpected: $e');
      return false;
    }
  }
}
