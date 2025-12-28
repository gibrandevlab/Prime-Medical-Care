class Pegawai {
  int? id;
  String nip;
  String nama;
  String tanggalLahir;
  String nomorTelepon;
  String email;
  String password;

  Pegawai({
    this.id,
    required this.nip,
    required this.nama,
    required this.tanggalLahir,
    required this.nomorTelepon,
    this.email = '',
    this.password = '',
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
    return Pegawai(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nip: (json['nip'] ?? json['NIP'] ?? '').toString(),
      nama: (json['nama'] ?? json['name'] ?? '').toString(),
      tanggalLahir: (json['tanggal_lahir'] ?? json['tanggalLahir'] ?? '')
          .toString(),
      nomorTelepon: (json['nomor_telepon'] ?? json['nomorTelepon'] ?? '')
          .toString(),
      email: (json['email'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nip': nip,
      'nama': nama,
      'tanggal_lahir': tanggalLahir,
      'nomor_telepon': nomorTelepon,
      'email': email,
      'password': password,
    };
  }
}
