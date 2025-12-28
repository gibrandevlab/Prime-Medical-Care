import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/poli.dart';

class PoliService {
  final Dio _dio = dioClient;

  Future<List<Poli>> getAll() async {
    try {
      final resp = await _dio.get('/poli');
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => Poli.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('PoliService.getAll error: ${e.message}');
      return [];
    } catch (e) {
      print('PoliService.getAll unexpected: $e');
      return [];
    }
  }

  Future<Poli?> getById(int id) async {
    try {
      final resp = await _dio.get('/poli/$id');
      final data = resp.data;
      if (data is Map<String, dynamic>) return Poli.fromJson(data);
      if (data is Map) return Poli.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      print('PoliService.getById error: ${e.message}');
      return null;
    } catch (e) {
      print('PoliService.getById unexpected: $e');
      return null;
    }
  }

  Future<Poli?> add(Poli p) async {
    try {
      final resp = await _dio.post('/poli', data: p.toJson());
      final data = resp.data;
      if (data is Map<String, dynamic>) return Poli.fromJson(data);
      if (data is Map) return Poli.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      print('PoliService.add error: ${e.message}');
      return null;
    } catch (e) {
      print('PoliService.add unexpected: $e');
      return null;
    }
  }

  Future<Poli?> update(Poli p, int id) async {
    try {
      final resp = await _dio.put('/poli/$id', data: p.toJson());
      final data = resp.data;
      if (data is Map<String, dynamic>) return Poli.fromJson(data);
      if (data is Map) return Poli.fromJson(Map<String, dynamic>.from(data));
      return null;
    } on DioException catch (e) {
      print('PoliService.update error: ${e.message}');
      return null;
    } catch (e) {
      print('PoliService.update unexpected: $e');
      return null;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('/poli/$id');
      return true;
    } on DioException catch (e) {
      print('PoliService.delete error: ${e.message}');
      return false;
    } catch (e) {
      print('PoliService.delete unexpected: $e');
      return false;
    }
  }
}
