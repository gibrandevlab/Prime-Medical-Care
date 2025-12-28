import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/pegawai.dart';

class PegawaiService {
  final Dio _dio = dioClient;

  Future<List<Pegawai>> getAll() async {
    try {
      final resp = await _dio.get('/pegawai');
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => Pegawai.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      developer.log(
        'PegawaiService.getAll error: ${e.message}',
        name: 'PegawaiService',
      );
      return [];
    } catch (e) {
      developer.log(
        'PegawaiService.getAll unexpected: $e',
        name: 'PegawaiService',
      );
      return [];
    }
  }

  Future<Pegawai?> getById(int id) async {
    try {
      final resp = await _dio.get('/pegawai/$id');
      final data = resp.data;
      if (data is Map<String, dynamic>) return Pegawai.fromJson(data);
      if (data is Map) return Pegawai.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      developer.log(
        'PegawaiService.getById error: ${e.message}',
        name: 'PegawaiService',
      );
      return null;
    } catch (e) {
      developer.log(
        'PegawaiService.getById unexpected: $e',
        name: 'PegawaiService',
      );
      return null;
    }
  }

  Future<Pegawai?> add(Pegawai p) async {
    try {
      final resp = await _dio.post('/pegawai', data: p.toJson());
      final data = resp.data;
      if (data is Map<String, dynamic>) return Pegawai.fromJson(data);
      if (data is Map) return Pegawai.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message;
      throw Exception(msg); 
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Pegawai?> update(Pegawai p, int id) async {
    try {
      final resp = await _dio.put('/pegawai/$id', data: p.toJson());
      final data = resp.data;
      if (data is Map<String, dynamic>) return Pegawai.fromJson(data);
      if (data is Map) return Pegawai.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      developer.log(
        'PegawaiService.update error: ${e.message}',
        name: 'PegawaiService',
      );
      return null;
    } catch (e) {
      developer.log(
        'PegawaiService.update unexpected: $e',
        name: 'PegawaiService',
      );
      return null;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('/pegawai/$id');
      return true;
    } on DioException catch (e) {
      developer.log(
        'PegawaiService.delete error: ${e.message}',
        name: 'PegawaiService',
      );
      return false;
    } catch (e) {
      developer.log(
        'PegawaiService.delete unexpected: $e',
        name: 'PegawaiService',
      );
      return false;
    }
  }
}
