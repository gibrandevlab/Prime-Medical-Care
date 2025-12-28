class Poli {
  final int? id;
  final String namaPoli;
  final String? keterangan;
  final String? gambar;

  Poli({this.id, required this.namaPoli, this.keterangan, this.gambar});

  factory Poli.fromJson(Map<String, dynamic> json) {
    return Poli(
      id: json['id'],
      namaPoli: json['nama_poli'] ?? '',
      keterangan: json['keterangan'],
      gambar: json['gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, 
      'nama_poli': namaPoli,
      if (keterangan != null) 'keterangan': keterangan,
      if (gambar != null) 'gambar': gambar,
    };
  }
}
