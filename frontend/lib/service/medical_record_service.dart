import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/medical_record.dart';

class MedicalRecordService {
  final Dio _dio = dioClient;

  Future<List<MedicalRecordModel>> listByPasien(int pasienId) async {
    try {
      final resp = await _dio.get('/medical-records/pasien/$pasienId');
      final data = resp.data;
      if (data is List)
        return data
            .map((e) => MedicalRecordModel.fromJson(e as Map<String, dynamic>))
            .toList();
      return [];
    } catch (e) {
      print('MedicalRecordService.listByPasien error: $e');
      return [];
    }
  }

  Future<MedicalRecordModel?> create(Map<String, dynamic> payload) async {
    try {
      final resp = await _dio.post('/medical-records', data: payload);
      final data = resp.data;
      if (data is Map<String, dynamic>)
        return MedicalRecordModel.fromJson(data);
      return null;
    } catch (e) {
      print('MedicalRecordService.create error: $e');
      return null;
    }
  }
}
