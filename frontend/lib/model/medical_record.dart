class MedicalRecordModel {
  final int? id;
  final int pasienId;
  final int? dokterId;
  final int? poliId;
  final String? anamnesa;
  final String? diagnosa;
  final String? tindakan;
  final String? resep;
  final String visitDate;

  MedicalRecordModel({
    this.id,
    required this.pasienId,
    this.dokterId,
    this.poliId,
    this.anamnesa,
    this.diagnosa,
    this.tindakan,
    this.resep,
    required this.visitDate,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'],
      pasienId: json['pasien_id'] ?? json['pasienId'] ?? 0,
      dokterId: json['dokter_id'] ?? json['dokterId'],
      poliId: json['poli_id'] ?? json['poliId'],
      anamnesa: json['anamnesa'] ?? null,
      diagnosa: json['diagnosa'] ?? null,
      tindakan: json['tindakan'] ?? null,
      resep: json['resep'] ?? null,
      visitDate: json['visit_date'] ?? json['visitDate'] ?? '',
    );
  }
}
