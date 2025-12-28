class Dokter {
  final int? id;
  final String nip;
  final String nama;
  final String nomorTelepon;
  final int? poliId;
  final String namaPoli;
  final String? email;
  final String? password;

  Dokter({
    this.id,
    required this.nip,
    required this.nama,
    required this.nomorTelepon,
    this.poliId,
    required this.namaPoli,
    this.email,
    this.password,
  });

  factory Dokter.fromJson(Map<String, dynamic> json) {
    return Dokter(
      id: json['id'],
      nip: json['nip'] ?? '',
      nama: json['nama'] ?? '',
      // Backend sends 'nomor_telepon' (snake_case)
      nomorTelepon: json['nomor_telepon'] ?? json['noTelp'] ?? '',
      poliId: json['poliId'],
      // Check if 'Poli' object exists, otherwise default
      namaPoli: (json['Poli'] != null && json['Poli']['nama_poli'] != null)
          ? json['Poli']['nama_poli']
          : 'Tidak ada Poli',
      email: json['email'] ?? null,
      password: json['password'] ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nip': nip,
      'nama': nama,
      'nomor_telepon': nomorTelepon,
      'poliId': poliId,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
    };
  }
}
